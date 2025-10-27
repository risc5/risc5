/*
 * bruteforce_google2_mt_fixed_partition.c
 *
 * 修正版：为每个线程分配不重叠的索引区间，避免重复计算。
 *
 * Usage:
 *   gcc -O2 -o bruteforce_google2_mt_fixed_partition bruteforce_google2_mt_fixed_partition.c -lcrypto -lpthread
 *   ./bruteforce_google2_mt_fixed_partition f.tar.gz [num_threads] [print_every_N] >1.out 2>&1
 *   ./bruteforce_google2_mt_fixed_partition f.tar.gz 128 1 >1.out 2>&1
 *
 * 默认 num_threads = 1 (or pass desired), 默认 print_every_N = 500
 */

#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <pthread.h>
#include <errno.h>
#include <stdatomic.h>
#include <ctype.h>

#include <openssl/evp.h>
#include <openssl/err.h>

#define PREFIX "google"
#define PREFIX_LEN 6
#define SALT_MAGIC "Salted__"
#define SALT_MAGIC_LEN 8
#define SALT_LEN 8
#define GZIP_MAGIC_0 0x1f
#define GZIP_MAGIC_1 0x8b
#define GZIP_MAGIC_2 0x08

/* printable ASCII inclusive range used previously: 33 .. 126
   若需改为 32..126，请把 CHAR_MIN 改为 32 */
#define CHAR_MIN 33
#define CHAR_MAX 126

typedef struct {
    unsigned char *enc_buf;
    size_t enc_len;
    size_t payload_offset;
    unsigned char salt[SALT_LEN];
    int has_salt;
    int thread_id;
    int num_threads;
    unsigned int print_every;
    atomic_uint *global_counter;
    atomic_int *found_flag;
    pthread_mutex_t *write_mutex;
    pthread_mutex_t *print_mutex;
    const char *orig_name;
    unsigned int start_idx;
    unsigned int end_idx;
} worker_arg_t;

/* read file fully */
static unsigned char *read_file(const char *path, size_t *out_len) {
    FILE *f = fopen(path, "rb"); if (!f) return NULL;
    if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return NULL; }
    long l = ftell(f); if (l < 0) { fclose(f); return NULL; }
    rewind(f);
    size_t len = (size_t)l;
    unsigned char *buf = malloc(len ? len : 1); if (!buf) { fclose(f); return NULL; }
    if (len > 0) { if (fread(buf, 1, len, f) != len) { free(buf); fclose(f); return NULL; } }
    fclose(f);
    *out_len = len; return buf;
}

/* quick decrypt no padding for first 'cipher_len' bytes (must be multiple of 16) */
static int quick_decrypt_no_padding(const unsigned char *cipher, int cipher_len,
                                    const unsigned char *key, const unsigned char *iv,
                                    unsigned char *out, int out_size) {
    if (cipher_len <= 0 || (cipher_len % 16) != 0) return -1;
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new(); if (!ctx) return -1;
    if (EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv) != 1) { EVP_CIPHER_CTX_free(ctx); return -1; }
    EVP_CIPHER_CTX_set_padding(ctx, 0);
    int outl = 0, total = 0;
    if (EVP_DecryptUpdate(ctx, out, &outl, cipher, cipher_len) != 1) { EVP_CIPHER_CTX_free(ctx); return -1; }
    total += outl;
    /* ignore final/padding errors */
    EVP_DecryptFinal_ex(ctx, out + total, &outl);
    EVP_CIPHER_CTX_free(ctx);
    return total;
}

/* full decrypt with padding (strict) - returns 0 on success */
static int full_decrypt_and_write_strict(const char *outfile,
                                         const unsigned char *enc_buf, size_t enc_len, size_t payload_offset,
                                         const unsigned char *key, const unsigned char *iv) {
    const unsigned char *cipher = enc_buf + payload_offset;
    int cipher_len = (int)(enc_len - payload_offset);
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new(); if (!ctx) return -1;
    if (EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv) != 1) { EVP_CIPHER_CTX_free(ctx); return -1; }
    FILE *out = fopen(outfile, "wb"); if (!out) { EVP_CIPHER_CTX_free(ctx); return -1; }
    int chunk = 4096;
    unsigned char outbuf[8192];
    int outl = 0;
    int processed = 0;
    while (processed < cipher_len) {
        int to_do = cipher_len - processed;
        if (to_do > chunk) to_do = chunk;
        if (EVP_DecryptUpdate(ctx, outbuf, &outl, cipher + processed, to_do) != 1) { fclose(out); EVP_CIPHER_CTX_free(ctx); return -1; }
        if (outl > 0) {
            if (fwrite(outbuf, 1, outl, out) != (size_t)outl) { fclose(out); EVP_CIPHER_CTX_free(ctx); return -1; }
        }
        processed += to_do;
    }
    if (EVP_DecryptFinal_ex(ctx, outbuf, &outl) != 1) { fclose(out); EVP_CIPHER_CTX_free(ctx); return -1; }
    if (outl > 0) {
        if (fwrite(outbuf, 1, outl, out) != (size_t)outl) { fclose(out); EVP_CIPHER_CTX_free(ctx); return -1; }
    }
    fclose(out);
    EVP_CIPHER_CTX_free(ctx);
    return 0;
}

/* fallback cpu count */
static int get_cpu_count_fallback(void) {
#if defined(_SC_NPROCESSORS_ONLN)
    long n = sysconf(_SC_NPROCESSORS_ONLN);
    if (n > 0) return (int)n;
#endif
#if defined(__APPLE__) || defined(__MACH__)
    int cnt = 0; size_t len = sizeof(cnt);
    if (sysctlbyname("hw.ncpu", &cnt, &len, NULL, 0) == 0) if (cnt > 0) return cnt;
#endif
    return 4;
}

/* hex-encode 2 bytes for filename */
static void hex_encode2(const unsigned char *p, char *out, int outlen) {
    const char *hex = "0123456789abcdef";
    int pos = 0;
    for (int i = 0; i < 2 && pos + 2 < outlen; ++i) {
        unsigned char b = p[i];
        out[pos++] = hex[(b >> 4) & 0xF];
        out[pos++] = hex[b & 0xF];
    }
    out[pos] = 0;
}

/* worker: processes [start_idx..end_idx] inclusive */
static void *worker_main(void *argp) {
    worker_arg_t *arg = (worker_arg_t *)argp;
    unsigned char pwbuf[PREFIX_LEN + 2];
    memcpy(pwbuf, PREFIX, PREFIX_LEN);

    const unsigned char *cipher_start = arg->enc_buf + arg->payload_offset;
    int cipher_avail = (int)(arg->enc_len - arg->payload_offset);
    if (cipher_avail <= 0) return NULL;

    const unsigned int width = (unsigned int)(CHAR_MAX - CHAR_MIN + 1);
    const unsigned int total = width * width;
    unsigned char plain[64];

    for (unsigned int idx = arg->start_idx; idx <= arg->end_idx; ++idx) {
        if (atomic_load(arg->found_flag)) break;

        unsigned int i = idx / width;
        unsigned int j = idx % width;
        unsigned char c1 = (unsigned char)(CHAR_MIN + i);
        unsigned char c2 = (unsigned char)(CHAR_MIN + j);
        pwbuf[PREFIX_LEN + 0] = c1;
        pwbuf[PREFIX_LEN + 1] = c2;
        int pwlen = PREFIX_LEN + 2;

        unsigned int prev = atomic_fetch_add_explicit(arg->global_counter, 1u, memory_order_relaxed) + 1;
        if (arg->print_every > 0 && (prev % arg->print_every) == 0) {
            pthread_mutex_lock(arg->print_mutex);
            if (isprint(c1) && isprint(c2)) {
                fprintf(stderr, "[GLOBAL] Tried %u / %u candidates (last tried: google%c%c) (thread %d)\n",
                        prev, total, (char)c1, (char)c2, arg->thread_id);
            } else {
                fprintf(stderr, "[GLOBAL] Tried %u / %u candidates (thread %d)\n", prev, total, arg->thread_id);
            }
            pthread_mutex_unlock(arg->print_mutex);
        }

        /* DERIVE key/iv using OpenSSL default digest = SHA256 here (to match shell default on many systems) */
        unsigned char key[32], iv[16];
        int kb = EVP_BytesToKey(EVP_aes_256_cbc(), EVP_sha256(),
                                arg->has_salt ? arg->salt : NULL,
                                pwbuf, pwlen, 1, key, iv);
        if (kb != 32) continue;

        int dec = quick_decrypt_no_padding(cipher_start, 16, key, iv, plain, sizeof(plain));
        if (dec < 3) continue;

        if ((unsigned char)plain[0] == GZIP_MAGIC_0 &&
            (unsigned char)plain[1] == GZIP_MAGIC_1 &&
            (unsigned char)plain[2] == GZIP_MAGIC_2) {
            /* winner attempt */
            int expected = 0;
            if (atomic_compare_exchange_strong(arg->found_flag, &expected, 1)) {
                /* form output filename */
                char hex2[8];
                hex_encode2(pwbuf + PREFIX_LEN, hex2, sizeof(hex2));
                char outname[512];
                const char *orig = arg->orig_name ? arg->orig_name : "f";
                snprintf(outname, sizeof(outname), "%s_decrypted_thread%d_%s.tar.gz", orig, arg->thread_id, hex2);

                pthread_mutex_lock(arg->write_mutex);
                int w = full_decrypt_and_write_strict(outname, arg->enc_buf, arg->enc_len, arg->payload_offset, key, iv);
                if (w == 0) {
                    pthread_mutex_lock(arg->print_mutex);
                    if (isprint(c1) && isprint(c2)) {
                        fprintf(stderr, "[T%d] Found password: google%c%c -> wrote %s\n", arg->thread_id, (char)c1, (char)c2, outname);
                    } else {
                        fprintf(stderr, "[T%d] Found password: google%02x%02x -> wrote %s\n", arg->thread_id, c1, c2, outname);
                    }
                    pthread_mutex_unlock(arg->print_mutex);
                } else {
                    pthread_mutex_lock(arg->print_mutex);
                    fprintf(stderr, "[T%d] Candidate found but full decrypt/write failed\n", arg->thread_id);
                    pthread_mutex_unlock(arg->print_mutex);
                }
                pthread_mutex_unlock(arg->write_mutex);
            }
            break;
        }
    }

    return NULL;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s encrypted_file [num_threads] [print_every_N]\n", argv[0]);
        return 2;
    }
    const char *enc_path = argv[1];
    int num_threads = 1;
    unsigned int print_every = 500;
    if (argc >= 3) num_threads = atoi(argv[2]);
    if (num_threads <= 0) num_threads = get_cpu_count_fallback();
    if (argc >= 4) {
        int p = atoi(argv[3]);
        if (p > 0) print_every = (unsigned int)p;
    }

    size_t enc_len = 0;
    unsigned char *enc_buf = read_file(enc_path, &enc_len);
    if (!enc_buf) { fprintf(stderr, "Failed to read file: %s\n", enc_path); return 3; }
    if (enc_len < 16) { fprintf(stderr, "File too short or invalid\n"); free(enc_buf); return 4; }

    int has_salt = 0;
    unsigned char salt[SALT_LEN] = {0};
    size_t payload_offset = 0;
    if (enc_len >= SALT_MAGIC_LEN + SALT_LEN && memcmp(enc_buf, SALT_MAGIC, SALT_MAGIC_LEN) == 0) {
        has_salt = 1;
        memcpy(salt, enc_buf + SALT_MAGIC_LEN, SALT_LEN);
        payload_offset = SALT_MAGIC_LEN + SALT_LEN;
        fprintf(stderr, "Detected Salted__ header; using salt.\n");
    } else {
        has_salt = 0;
        payload_offset = 0;
        fprintf(stderr, "No Salted__ header detected; assuming no salt.\n");
    }

    OpenSSL_add_all_algorithms();
    ERR_load_crypto_strings();

    unsigned int width = (unsigned int)(CHAR_MAX - CHAR_MIN + 1);
    unsigned int total = width * width;

    pthread_t *tids = calloc((size_t)num_threads, sizeof(pthread_t));
    worker_arg_t *args = calloc((size_t)num_threads, sizeof(worker_arg_t));
    if (!tids || !args) { fprintf(stderr, "Allocation failure\n"); free(enc_buf); return 5; }

    atomic_uint global_counter;
    atomic_init(&global_counter, 0u);
    atomic_int found_flag;
    atomic_init(&found_flag, 0);
    pthread_mutex_t write_mutex;
    pthread_mutex_init(&write_mutex, NULL);
    pthread_mutex_t print_mutex;
    pthread_mutex_init(&print_mutex, NULL);

    /* compute per-thread index ranges */
    unsigned int per = total / (unsigned int)num_threads;
    unsigned int rem = total % (unsigned int)num_threads;
    unsigned int cur = 0;
    for (int t = 0; t < num_threads; ++t) {
        unsigned int cnt = per + (t < (int)rem ? 1u : 0u);
        unsigned int start = cur;
        unsigned int end = (cnt == 0) ? (start - 1) : (start + cnt - 1);
        cur += cnt;
        args[t].enc_buf = enc_buf;
        args[t].enc_len = enc_len;
        args[t].payload_offset = payload_offset;
        args[t].has_salt = has_salt;
        if (has_salt) memcpy(args[t].salt, salt, SALT_LEN);
        args[t].thread_id = t;
        args[t].num_threads = num_threads;
        args[t].print_every = print_every;
        args[t].global_counter = &global_counter;
        args[t].found_flag = &found_flag;
        args[t].write_mutex = &write_mutex;
        args[t].print_mutex = &print_mutex;
        args[t].orig_name = enc_path;
        args[t].start_idx = start;
        args[t].end_idx = end;
        if (cnt > 0) {
            if (pthread_create(&tids[t], NULL, worker_main, &args[t]) != 0) {
                fprintf(stderr, "Failed to create thread %d: %s\n", t, strerror(errno));
            }
        } else {
            /* no work for this thread; create but it will exit quickly */
            if (pthread_create(&tids[t], NULL, worker_main, &args[t]) != 0) {
                fprintf(stderr, "Failed to create thread %d: %s\n", t, strerror(errno));
            }
        }
    }

    for (int t = 0; t < num_threads; ++t) pthread_join(tids[t], NULL);

    if (atomic_load(&found_flag)) {
        fprintf(stderr, "Password candidate found; check output files like '%s_decrypted_thread<id>_<hex>.tar.gz'\n", enc_path);
    } else {
        unsigned int tried = atomic_load(&global_counter);
        fprintf(stderr, "Not found in google+2 printable chars search space. Tried %u candidates.\n", tried);
    }

    pthread_mutex_destroy(&write_mutex);
    pthread_mutex_destroy(&print_mutex);
    free(tids);
    free(args);
    EVP_cleanup();
    ERR_free_strings();
    free(enc_buf);
    return 0;
}

