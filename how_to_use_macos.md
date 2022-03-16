* macos change terminal tag name shortcut

```shell 
Shift+Command+i
```


```shell

find . -iname "*.md" -print0 | xargs -I{} -0 grep -i 寅申巳亥 "{}"

```shell




Howto Make Find Xargs Grep Robust to Spaces in Filenames on a Mac
JUN 24TH, 2012
The unix pattern for filtering files with a predicate then searching within them is find | xargs | grep. For example, to search every file whose filename contains notes for a line containing mysql

1
$ find . -iname "*notes*" | xargs grep -i mysql
Unfortunately, on OSX this is not robust to spaces or quotes in filenames. Thus if you have a filename like

1
./Dropquest 2012/Captain's Logs/Chapter 1.txt
in your search path the typical find | xargs | grep invocation will terminate with the error

1
xargs: unterminated quote
The first thing to know is you can use the -t parameter in xargs to at least tell you which filename it’s dying on, but that’s of limited use in making the command work. Even using -I{} with xargs and grep to surround the filename with quotes doesn’t fix this.

1
$ find . -iname "*notes*" | xargs -I{} grep -i mysql "{}"
Many people must have run into this problem because there is a simple solution that all the tools understand: use nulls instead of newlines to delimit files.

1
$ find . -iname "*notes*" -print0 | xargs -I{} -0 grep -i mysql "{}"
and it works!

