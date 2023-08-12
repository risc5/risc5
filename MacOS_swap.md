## MacOS 关闭和开启虚拟内存(swap)  
  
### 作者  
digoal  
  
### 日期  
2021-11-03  
  
### 标签  
PostgreSQL , MacOS , swap     
  
----  
  
## 背景  
## 本文方法关闭swap无效, 请参考另一篇
[《禁用 MacOS 的 Swap 分区》](../202212/20221207_01.md)  

## 以下内容依旧保留, 但是对禁用swap没用.   
内存够大时建议关闭虚拟内存, 因为使用虚拟内存的性能差, 而且影响SSD寿命.    
  
为什么在配置有很大内存(例如16GB以上)的情况下MacOS还会疯狂的使用swap, 可能和numa有关?  参考知识点：   
  
[《大内存, 大并发应用的NUMA内存管理配置策略 - PostgreSQL numa配置》](../202110/20211019_01.md)    
  
[《DB吐槽大会,第81期 - PG 未针对 NUMA 优化》](../202110/20211026_05.md)    
  
## 关闭MacOS虚拟内存  
  
1、重启并进入恢复模式, 不同版本的MAC进入恢复模式的方法可能不一样.   
- macbook pro 2018版的进入恢复模式方式, 正常启动的情况下, 选择重启电脑, 然后立即按下 `Command+R` 不要放手, 直到进入恢复模式再放手.  
- Mac M1进入恢复模式方式。就在电脑完全关机的情况下，一直按着电源键不放，提示你继续按着电源键就可以进入，然后直到提示你正在进入恢复模式就可以放手了。  
  
2、关闭安全性保护  
  
在菜单栏工具中打开终端执行  
  
```  
csrutil disable  
```  
  
3、重启电脑进入普通模式  
  
4、关闭虚拟内存  
  
打开终端执行  
  
```  
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist  
```  
  
5、再次重启并恢复模式  
  
6、开启安全性保护  
  
```  
csrutil enable  
```  
  
7、重启电脑进入普通模式, 查询虚拟内存  
  
```  
sysctl vm.swapusage  
  
vm.swapusage: total = 0.00M  used = 0.00M  free = 0.00M  (encrypted)  
```  
  
## 启用MacOS虚拟内存  
  
  
1、重启并进入恢复模式, 不同版本的MAC进入恢复模式的方法可能不一样.   
- macbook pro 2018版的进入恢复模式方式, 正常启动的情况下, 选择重启电脑, 然后立即按下 `Command+R` 不要放手, 直到进入恢复模式再放手.  
- Mac M1进入恢复模式方式。就在电脑完全关机的情况下，一直按着电源键不放，提示你继续按着电源键就可以进入，然后直到提示你正在进入恢复模式就可以放手了。  
  
2、关闭安全性保护  
  
在菜单栏工具中打开终端执行  
  
```  
csrutil disable  
```  
  
3、重启电脑进入普通模式  
  
4、启用虚拟内存  
  
打开终端执行  
  
```  
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist  
```  
  
5、再次重启并恢复模式  
  
6、开启安全性保护  
  
```  
csrutil enable  
```  
  
7、重启电脑进入普通模式, 查询虚拟内存  
  
在刚开机时，swap用量为0。于是我打开很多应用，发现物理内存用量大约10g时发现swap开始使用。然后随着我不断关闭应用，出现了如下的结果。因此大致可以得出一个结论，swap的用量是系统动态调整的，内存用量越大，swap用量越大。  
  
```  
% sysctl vm.swapusage  
vm.swapusage: total = 2048.00M  used = 1235.75M  free = 812.25M  (encrypted)  
% sysctl vm.swapusage  
vm.swapusage: total = 2048.00M  used = 1075.75M  free = 972.25M  (encrypted)  
% sysctl vm.swapusage  
vm.swapusage: total = 1024.00M  used = 264.00M  free = 760.00M  (encrypted)  
```  
  
## 参考  
https://blog.csdn.net/qq_29911647/article/details/114952758  
  
https://blog.csdn.net/qq_29496469/article/details/114222398  
    
  
  
#### [期望 PostgreSQL 增加什么功能?](https://github.com/digoal/blog/issues/76 "269ac3d1c492e938c0191101c7238216")
  
  
#### [类似Oracle RAC架构的PostgreSQL已开源: 阿里云PolarDB for PostgreSQL云原生分布式开源数据库!](https://github.com/ApsaraDB/PolarDB-for-PostgreSQL "57258f76c37864c6e6d23383d05714ea")
  
  
#### [PostgreSQL 解决方案集合](https://yq.aliyun.com/topic/118 "40cff096e9ed7122c512b35d8561d9c8")
  
  
#### [德哥 / digoal's github - 公益是一辈子的事.](https://github.com/digoal/blog/blob/master/README.md "22709685feb7cab07d30f30387f0a9ae")
  
  
![digoal's wechat](../pic/digoal_weixin.jpg "f7ad92eeba24523fd47a6e1a0e691b59")
  
  
#### [PolarDB 学习图谱: 训练营、培训认证、在线互动实验、解决方案、生态合作、写心得拿奖品](https://www.aliyun.com/database/openpolardb/activity "8642f60e04ed0c814bf9cb9677976bd4")
  
