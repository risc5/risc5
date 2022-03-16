linux find命令-print0和xargs中-0使用技巧（转载）
本文介绍了linux find命令中-print0和xargs中-0用法技巧，一些find命令的使用经验，需要的朋友参考下。

本节内容：
linux find命令中-print0和xargs中-0的用法。

默认情况下, find命令每输出一个文件名, 后面都会接着输出一个换行符 ('n'), 因此find 的输出都是一行一行的:
 

[bash-4.1.5] ls -l
total 0
-rw-r--r-- 1 root root 0 2010-08-02 18:09 file1.log
-rw-r--r-- 1 root root 0 2010-08-02 18:09 file2.log
[bash-4.1.5] find -name '*.log'
./file2.log
./file1.log
比如用find命令把所有的 .log 文件删掉, 可以这样配合 xargs 一起用:
 

[bash-4.1.5] find -name '*.log'
./file2.log
./file1.log
[bash-4.1.5] find -name '*.log' | xargs rm
[bash-4.1.5] find -name '*.log'
find命令结合xargs 真的很强大. 然而:
 

[bash-4.1.5] ls -l
total 0
-rw-r--r-- 1 root root 0 2010-08-02 18:12 file 1.log
-rw-r--r-- 1 root root 0 2010-08-02 18:12 file 2.log
[bash-4.1.5] find -name '*.log'
./file 1.log
./file 2.log
[bash-4.1.5] find -name '*.log' | xargs rm
rm: cannot remove `./file': No such file or directory
rm: cannot remove `1.log': No such file or directory
rm: cannot remove `./file': No such file or directory
rm: cannot remove `2.log': No such file or directory
 
原因其实很简单, xargs 默认是以空白字符 (空格, TAB, 换行符) 来分割记录的, 因此文件名 ./file 1.log 被解释成了两个记录 ./file 和 1.log, 不幸的是 rm 找不到这两个文件.

为了解决此类问题, 让 find命令在打印出一个文件名之后接着输出一个 NULL 字符 ('') 而不是换行符, 然后再告诉 xargs 也用 NULL 字符来作为记录的分隔符. 这就是 find 的 -print0 和 xargs 的 -0 的来历吧.
 

[bash-4.1.5] ls -l
total 0
-rw-r--r-- 1 root root 0 2010-08-02 18:12 file 1.log
-rw-r--r-- 1 root root 0 2010-08-02 18:12 file 2.log
[bash-4.1.5] find -name '*.log' -print0 | hd
0 1 2 3 4 5 6 7 8 9 A B C D E F |0123456789ABCDEF|
--------+--+--+--+--+---+--+--+--+---+--+--+--+---+--+--+--+--+----------------|
00000000: 2e 2f 66 69 6c 65 20 31 2e 6c 6f 67 00 2e 2f 66 |./file 1.log../f|
00000010: 69 6c 65 20 32 2e 6c 6f 67 00 |ile 2.log. |
[bash-4.1.5] find -name '*.log' -print0 | xargs -0 rm
[bash-4.1.5] find -name '*.log'
 
你可能要问了, 为什么要选 '' 而不是其他字符做分隔符呢? 这个也容易理解: 一般的编程语言中都用 '' 来作为字符串的结束标志, 文件的路径名中不可能包含 '' 字符.

分享一些find命令与xargs的实例：

删除以html结尾的10天前的文件，包括带空格的文件：
 

find /usr/local/backups -name "*.html" -mtime +10 -print0 |xargs -0 rm -rfvfind /usr/local/backups -mtime +10 -name "*.html" -exec rm -rf {} ;
 
find -print 和 -print0的区别:

-print 在每一个输出后会添加一个回车换行符，而-print0则不会。
当前目录下文件从大到小排序（包括隐藏文件），文件名不为"."：
 

find . -maxdepth 1 ! -name "." -print0 | xargs -0 du -b | sort -nr | head -10 | nl
nl：可以为输出列加上编号,与cat -n相似，但空行不编号
以下功能同上，但不包括隐藏文件：
 

for file in *; do du -b "$file"; done|sort -nr|head -10|nlx
args结合sed替换：
 

find . -name "*.txt" -print0 | xargs -0 sed -i 's/aaa/bbb/g'
xargs结合grep：
 

find . -name '*.txt' -type f -print0 |xargs -0 grep -n 'aaa'    #“-n”输出行号
本文原始链接：http://www.jbxue.com/LINUXjishu/24429.html
