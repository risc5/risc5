## Note Is More Power Than Memory 
> We need to clear our memory at intervals. Donot remember it 

* find ./ -perm /+x -type f 

1 2 4 more difficutly to remember

1 ----<>x 

2 ----<>w 

4 ----<>r 


* 查找并删除*.so文件

find . -name "*.so" | xargs rm
* 查找并拷贝*.so文件

find . -name "*.so" | xargs -i cp {} ./tmp/

* 拷贝当前目录下所有*.so文件到./tmp/下

ls *.so | xargs -i cp {} ./tmp/


* Open the current dir

 alias opwd='nautilus `pwd`'
