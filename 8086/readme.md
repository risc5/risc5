1. 找到配置文件 dosbox-0.74-3.conf
在 Mac 上，这个文件通常是隐藏的。你可以通过以下方法找到它：

打开 Finder。

在顶部菜单栏选择 前往 -> 前往文件夹...（或者按快捷键 Shift + Command + G）。

输入以下路径： ~/Library/Preferences/

在该目录下寻找名为 DOSBox 0.74-3 Preferences 的文件（注：文件名可能略有不同，但通常以 DOSBox 开头）。





~~~
[autoexec]
# Lines in this section will be run at startup.
# You can put your MOUNT lines here.

# 1. 挂载目录（注意 Mac 路径名区分大小写，且路径中有空格要用引号）
MOUNT C ~/8086

# 2. 切换到虚拟的 C 盘
C:

# 3. 设置路径，方便直接调用工具
SET PATH=%PATH%;C:\
~~~

~~~

~~~



masm hello.asm;

link hello.obj;

hello.exe