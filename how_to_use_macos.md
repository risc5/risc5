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

![vim cheet sheet](./images/screen/Loog_screen.png)







