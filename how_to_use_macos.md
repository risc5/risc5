### Some Tips For Macos

> Author: Jello Huang



* Check macbook cpu temperature

  ~~~
  sudo powermetrics|grep temp
  ~~~

  



* zip and encrypt  file

  ~~~
  zip -e file.zip file.txt
  zip -er filefold.zip filefold
  ~~~

  

* macbook  terminal next tab and provious tab  

  ~~~
  next  control+ ⇥ tab
  provious control+shift+ ⇥ tab
  
  ~~~

  

* macos change terminal tag name shortcut

```shell 
Shift+Command+i
```

* How to grep file use find

```shell

# xargs unterminated quote 
find . -iname "*.md" -print0 | xargs -I{} -0 grep -i 寅申巳亥 "{}"


find . -name "*.md" -print0 | xargs  -0 grep "阳干十神表"




```
https://github.com/risc5/risc5/blob/master/print0.md

原因其实很简单, xargs 默认是以空白字符 (空格, TAB, 换行符) 来分割记录的, 因此文件名 ./file 1.log 被解释成了两个记录 ./file 和 1.log, 不幸的是 rm 找不到这两个文件.

为了解决此类问题, 让 find命令在打印出一个文件名之后接着输出一个 NULL 字符 ('') 而不是换行符, 然后再告诉 xargs 也用 NULL 字符来作为记录的分隔符. 这就是 find 的 -print0 和 xargs 的 -0 的来历吧.






##### Howto Make Find Xargs Grep Robust to Spaces in Filenames on a Mac

JUN 24TH, 2012

The unix pattern for filtering files with a predicate then searching within them is `find | xargs | grep`. For example, to search every file whose filename contains notes for a line containing mysql



```
$ find . -iname "*notes*" | xargs grep -i mysql 
```

Unfortunately, on OSX this is not robust to spaces or quotes in filenames. Thus if you have a filename like



```
./Dropquest 2012/Captain's Logs/Chapter 1.txt 
```

in your search path the typical `find | xargs | grep` invocation will terminate with the error



```
xargs: unterminated quote 
```

The first thing to know is you can use the `-t` parameter in `xargs` to at least tell you which filename it’s dying on, but that’s of limited use in making the command work. Even using `-I{}` with `xargs` and `grep` to surround the filename with quotes doesn’t fix this.



```
$ find . -iname "*notes*" | xargs -I{} grep -i mysql "{}" 
```

Many people must have run into this problem because there is a simple solution that all the tools understand: use nulls instead of newlines to delimit files.



```
find . -iname "*.md" -print0 | xargs -I{} -0 grep -i mysql "{}" 
```

```
neofetch
```

and it works!



##### 上面都太难记忆了

~~~shell

find . -name "*.md" -exec grep -Hn "甲乙" {} \;

grep -rin "甲乙" --include="*.md" .


~~~



- `-exec`: 此选项指示 `find` 为每个找到的文件执行命令。
- `grep`: 此命令用于搜索文件中是否存在字符串 "hello world"。
- `-H`: 此选项指示 `grep` 打印文件名以及匹配的行。
- `-n`: 此选项指示 `grep` 打印匹配行所在的行的行号。
- `{}`: 此占位符将替换为正在处理的文件的实际文件名。
- `\;`: 此字符是 `-exec` 命令的终止符。





~~~shell

find . -name "*.md" -exec grep -l "hello world" {} \;



~~~

`-l` 参数表示只输出包含匹配字符串的文件名，而不显示匹配的具体行内容。





### 截长图 屏幕

谷歌浏览器, F12打开开发者模式，使用快捷键 Ctrl+Shift+P，Mac 当中是 Command+Shift+P,输入screenshot，选full，即可以
最近在某个网站上发现，capture full size 无法截取全屏。 可能是网页设置了 body 高度为 100% 所致。去掉该属性即可正常使用

![vim cheet sheet](./images/screen/Loog_screen.png)






### macbook 休眠问题

macOS 的睡眠有两种状态
不断电，数据存储在内存中，可以快速恢复。我们称这种状态为睡眠（Sleep）
断电，数据存储在硬盘中，恢复得较慢。我们称这种状态为休眠（Hibernate/Stand-by）
睡眠和休眠可以组合出三种模式，由 hibernatemode 控制
hibernatemode = 0，这是桌面设备的默认值。系统只睡眠，不休眠，不将数据存储在硬盘中。
hibernatemode = 3，这是移动设备的默认值。系统默认睡眠，在一定时间后或电量低于阈值将数据存储在硬盘中，而后休眠。这是所谓的安全睡眠（Safe-Sleep）。
hibernatemode = 25。只休眠，不睡眠。
无论是安全睡眠模式还是休眠模式，从磁盘上恢复时，都会需要一定的时间（经测试，大约 3 秒钟）屏幕才会被点亮。
对于 hibernatemode = 3，即安全睡眠模式，又有几个参数来控制细节。

当剩余电量大于 highstandbythreshold（默认 50%）时，在 standbydelayhigh 秒（默认 86,400，即一整天）后进入休眠。
当剩余电量小于 highstandbythreshold 时，在 standbydelaylow 秒（默认 10,800，即三小时）后进入休眠



~~~shell

 When Using Battery
sudo pmset -b hibernatemode 25
sudo pmset -b highstandbythreshold 90
sudo pmset -b standbydelayhigh 3600  # 1 hour
sudo pmset -b standbydelaylow  300  # 5 minute
 When Using AC Power
sudo pmset -c hibernatemode 3
sudo pmset -c highstandbythreshold 80
sudo pmset -c standbydelayhigh 86400  # 24 hours
sudo pmset -c standbydelaylow  10800  # 3 hours
~~~


https://liam.page/2020/07/26/change-hibernatemode-to-save-battery-on-macOS/ 





### Install nginx



~~~shell

brew install nginx



Docroot is: /usr/local/var/www

The default port has been set in /usr/local/etc/nginx/nginx.conf to 8080 so that
nginx can run without sudo.

nginx will load all files in /usr/local/etc/nginx/servers/.

To start nginx now and restart at login:
  brew services start nginx
Or, if you don't want/need a background service you can just run:
  /usr/local/opt/nginx/bin/nginx -g daemon\ off\;
  

~~~





### **安装ubuntu**

| 方案           | 适用于 Intel Mac | 适用于 T2 MacBook Pro 2019 | 适合人群                           |
| -------------- | ---------------- | -------------------------- | ---------------------------------- |
| **t2linux**    | ✅                | ✅（最佳选择）              | 直接开箱即用，无需额外驱动修复     |
| **Ubuntu**     | ✅                | ❌（需手动修复）            | 适合 Ubuntu 用户，愿意手动安装驱动 |
| **Fedora**     | ✅                | ❌（需手动修复）            | 适合喜欢较新内核的用户             |
| **Arch Linux** | ✅                | ❌（需自己编译 T2 驱动）    | 适合高级用户                       |
| **Pop!_OS**    | ✅                | ❌（部分驱动需修复）        | 适合想要易用性的用户               |







### 進入雙系統

* 開機一直按住option按鍵 ，選擇然後進入ubuntu系統
* command+r 進入恢復系統





### Parallels 破解补丁



https://macked.app/parallels-desktop-20-crack.html

https://luoxx.top/archives/pd20-free-share

* 20.2.2
  * https://download.parallels.com/desktop/v20/20.2.2-55879/ParallelsDesktop-20.2.2-55879.dmg
  * 


### Macos破解网站

https://macked.app







### 快速进入桌面

想要，Mac 其实提供了好几种“丝滑”的方式，你可以根据自己习惯用键盘还是鼠标（触控板）来选择：

如果你习惯用触控板，这是最有“掌控感”的操作：

- **手势：** 使用 **大拇指和另外三根手指**，在触控板上做 **“捏合向外张开”** 的动作。
- **效果：** 就像用手把窗口拨开一样，桌面就出来了。反向捏合（向内收拢）即可找回窗口。





### 5. 快速呼出 Emoji 面板

如果你想在聊天或文档里加个表情 🚀：

- **快捷键：`Command + Control + Space`**
- **效果：** 弹出一个迷你的 Emoji 和符号选择框，输入关键词还能直接搜索。😉



### 1. 整理桌面的神技：使用“堆栈” (Stacks)

如果你的桌面乱得像被哈士奇拆过家，别一个个手动挪。

- **操作：** 在桌面空白处**右键点击**，选择 **“使用堆栈”** (Use Stacks)。
- **效果：** 所有的文件会瞬间按类型（图片、文档、PDF）自动整齐地堆在一起。点击堆栈展开，再点一下收回，桌面秒变清爽。

------

### 2. 万能的“隔空投送”快捷键 (AirDrop)

很多人还在 Finder 侧边栏里找 AirDrop，其实有更快的办法。

- **快捷键：`Command + Shift + R`**
- **效果：** 无论你在哪，直接闪现到 AirDrop 界面，准备接收或发送文件。

😳



### 1. 更改某一类文件的“全局”打开方式

如果你希望以后**所有**该后缀名的文件都用同一个软件打开：

1. **右键点击**该文件（或者按住 `Control` 键再点击）。
2. 在弹出的菜单中选择 **“显示简介”** (Get Info)，或者直接选中文件后按快捷键 `Command + I`。
3. 在弹出的窗口中，找到 **“打开方式”** (Open with) 这一栏。如果它是折叠的，点击左侧的小箭头展开



### 1. 浏览与文件处理（Finder 专用）

除了 `Command + I` 查看简介，这几个也是 Finder 里的神技：

- **`Space` (空格键) — 快速查看 (Quick Look)**：不用打开文件，直接预览图片、视频、PDF 甚至表格。这是 Mac 最受好评的功能。
- **`Command + D` — 快速副本**：一键克隆选中的文件。
- **`Command + Option + V` — 剪切文件**：Mac 默认没有“剪切”快捷键。你需要先 `Command + C` 拷贝，然后在目标位置按这个组合键，文件就会从原位“移”过来。
- **`Command + Delete` — 移至废纸篓**：不用再费力把文件往垃圾桶拖了。





### 3. 截图与屏幕录制

- **`Command + Shift + 4` — 截取选定区域**：按下后拖动鼠标选择区域。
  - *进阶：* 选定区域后按住 **`Space`**，你可以移动选框；或者按下 `Command + Shift + 4` 后再按 **`Space`**，相机图标会出现，点击任何窗口即可完美截取该窗口（带阴影的那种）。
- **`Command + Shift + 5` — 截图/录屏大面板**：调出录屏和截图的高级菜单，非常直观。





### 4. 隐藏的 Option 键魔法

`Option` 键在 Mac 上被称为“万能修改键”，有很多隐藏效果：

- **`Option + 点击顶部 Wi-Fi 图标`**：可以看到详细的信号强度、频率和 IP 地址。
- **`Option + 点击顶部音量图标`**：直接选择输出/输入设备（比如快速切换耳机或音响）。
- **`Option + 拖动文件`**：在拖动的同时自动创建一个该文件的副本。

------

### 5. 极速系统锁定

- **`Control + Command + Q` — 立即锁定屏幕**：离开座位时的必备操作。