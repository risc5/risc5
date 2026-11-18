#!/usr/bin/env python3
"""
将 vless.md 中的 vless:// 和 ss:// 节点链接转换为 Clash / Mihomo 单行流式 YAML 格式。

用法:
  python3 vless_to_clash.py                     # 默认读取 vless.md，输出到 clash_proxies.yaml
  python3 vless_to_clash.py -i in.md -o out.yaml
"""

import argparse
import base64
import re
import sys
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlparse


def yaml_scalar(val: str) -> str:
    """仅在包含特殊字符、空白或非 ASCII 字符时对字符串加双引号。"""
    if not val:
        return '""'
    if re.fullmatch(r"[A-Za-z0-9._-]+", val):
        return val
    escaped = val.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def parse_vless(uri: str) -> dict:
    parsed = urlparse(uri)
    qs = {k: v[0] for k, v in parse_qs(parsed.query, keep_blank_values=True).items()}

    name = unquote(parsed.fragment).strip() if parsed.fragment else f"vless_{parsed.hostname}_{parsed.port}"
    server = parsed.hostname or ""
    port = parsed.port or 443
    uuid = unquote(parsed.username or "")
    network = qs.get("type", "tcp") or "tcp"
    security = (qs.get("security", "") or "").lower()
    sni = qs.get("sni", "") or qs.get("host", "")
    fp = qs.get("fp", "")
    flow = qs.get("flow", "")
    pbk = qs.get("pbk", "")
    sid = qs.get("sid", "")

    fields = [
        ("name", yaml_scalar(name)),
        ("server", yaml_scalar(server)),
        ("port", str(port)),
        ("type", "vless"),
        ("uuid", yaml_scalar(uuid)),
    ]

    if security in ("tls", "reality"):
        fields.append(("tls", "true"))

    if flow:
        fields.append(("flow", yaml_scalar(flow)))

    if security == "reality":
        reality_parts = []
        if pbk:
            reality_parts.append(f"public-key: {yaml_scalar(pbk)}")
        if sid:
            reality_parts.append(f"short-id: {yaml_scalar(sid)}")
        if reality_parts:
            fields.append(("reality-opts", "{" + ", ".join(reality_parts) + "}"))

    if sni:
        fields.append(("servername", yaml_scalar(sni)))

    if fp:
        fields.append(("client-fingerprint", yaml_scalar(fp)))

    fields.append(("network", yaml_scalar(network)))

    if network == "ws":
        ws_parts = []
        ws_path = qs.get("path", "")
        ws_host = qs.get("host", "")
        if ws_path:
            ws_parts.append(f"path: {yaml_scalar(unquote(ws_path))}")
        if ws_host:
            ws_parts.append(f"headers: {{Host: {yaml_scalar(ws_host)}}}")
        if ws_parts:
            fields.append(("ws-opts", "{" + ", ".join(ws_parts) + "}"))
    elif network == "grpc":
        service_name = qs.get("serviceName", "")
        if service_name:
            fields.append(("grpc-opts", f"{{grpc-service-name: {yaml_scalar(service_name)}}}"))

    return {"name": name, "line": "  - {" + ", ".join(f"{k}: {v}" for k, v in fields) + "}"}


def _b64decode_padded(s: str) -> str:
    s = s.strip()
    padding = (-len(s)) % 4
    return base64.urlsafe_b64decode(s + "=" * padding).decode("utf-8")


def parse_ss(uri: str) -> dict:
    parsed = urlparse(uri)
    name = unquote(parsed.fragment).strip() if parsed.fragment else "ss_node"
    qs = {k: v[0] for k, v in parse_qs(parsed.query, keep_blank_values=True).items()}

    if parsed.hostname and parsed.port:
        # SIP002: ss://base64(method:password)@server:port?plugin=...#name
        userinfo = unquote(parsed.username or "")
        if ":" in userinfo:
            cipher, password = userinfo.split(":", 1)
        else:
            decoded = _b64decode_padded(userinfo)
            cipher, password = decoded.split(":", 1)
        server = parsed.hostname
        port = parsed.port
    else:
        # Legacy: ss://base64(method:password@server:port)#name
        raw_body = uri[len("ss://"):].split("#", 1)[0].split("?", 1)[0]
        decoded = _b64decode_padded(raw_body)
        cred, hostport = decoded.rsplit("@", 1)
        cipher, password = cred.split(":", 1)
        server, port_str = hostport.rsplit(":", 1)
        port = int(port_str)

    fields = [
        ("name", yaml_scalar(name)),
        ("type", "ss"),
        ("server", yaml_scalar(server)),
        ("port", str(port)),
        ("cipher", yaml_scalar(cipher)),
        ("password", yaml_scalar(password)),
    ]

    plugin_raw = unquote(qs.get("plugin", ""))
    if plugin_raw:
        parts = plugin_raw.split(";")
        plugin_name = parts[0]
        if plugin_name in ("obfs-local", "simple-obfs", "obfs"):
            plugin_name = "obfs"
        opts = {}
        for item in parts[1:]:
            if "=" in item:
                k, v = item.split("=", 1)
                if k == "obfs":
                    opts["mode"] = v
                elif k == "obfs-host":
                    opts["host"] = v
                else:
                    opts[k] = v
        fields.append(("plugin", yaml_scalar(plugin_name)))
        if opts:
            opts_str = ", ".join(f"{k}: {yaml_scalar(v)}" for k, v in opts.items())
            fields.append(("plugin-opts", "{ " + opts_str + " }"))

    fields.append(("udp", "false"))
    return {"name": name, "line": "  - {" + ", ".join(f"{k}: {v}" for k, v in fields) + " }"}


def convert_file(input_path: Path, output_path: Path) -> int:
    if not input_path.exists():
        print(f"错误: 找不到输入文件 {input_path}", file=sys.stderr)
        sys.exit(1)

    text = input_path.read_text(encoding="utf-8")
    # 逐行提取 vless:// 与 ss:// 链接（保留 #备注 中可能包含的空格）
    uris = []
    for raw_line in text.splitlines():
        m = re.search(r"(?:vless|ss)://.+", raw_line)
        if m:
            uri = m.group(0).strip().rstrip("`\"'<>")
            uris.append(uri)

    if not uris:
        print(f"未在 {input_path} 中找到任何 vless:// 或 ss:// 链接。", file=sys.stderr)
        sys.exit(1)

    entries = []
    seen_names = {}
    for uri in uris:
        try:
            if uri.startswith("vless://"):
                entry = parse_vless(uri)
            elif uri.startswith("ss://"):
                entry = parse_ss(uri)
            else:
                continue

            # 若重名则自动加序号后缀避免 Clash 报 duplicate proxy name
            base_name = entry["name"]
            if base_name in seen_names:
                seen_names[base_name] += 1
                new_name = f"{base_name}_{seen_names[base_name]}"
                entry["line"] = entry["line"].replace(
                    f"name: {yaml_scalar(base_name)}",
                    f"name: {yaml_scalar(new_name)}",
                    1,
                )
                entry["name"] = new_name
            else:
                seen_names[base_name] = 1

            entries.append(entry)
        except Exception as exc:
            print(f"警告: 跳过无法解析的链接 ({exc}): {uri[:60]}...", file=sys.stderr)

    lines = ["proxies:"]
    lines.extend(e["line"] for e in entries)
    lines.append("")
    lines.append("# 节点名称列表（可直接复制到 proxy-groups 下）:")
    lines.extend(f"#      - {yaml_scalar(e['name'])}" for e in entries)
    lines.append("")

    output_path.write_text("\n".join(lines), encoding="utf-8")
    return len(entries)


def main():
    parser = argparse.ArgumentParser(description="将 vless.md 转换为 Clash/Mihomo proxies 格式")
    parser.add_argument("-i", "--input", default="vless.md", help="输入文件 (默认: vless.md)")
    parser.add_argument("-o", "--output", default="clash_proxies.yaml", help="输出文件 (默认: clash_proxies.yaml)")
    args = parser.parse_args()

    in_path = Path(args.input)
    out_path = Path(args.output)
    count = convert_file(in_path, out_path)
    print(f"✅ 成功转换 {count} 个节点，已保存至: {out_path.resolve()}")


if __name__ == "__main__":
    main()
