



### boot 參數說明

 `nvram set flag_last_success=0`

- **意義：** 設置「最後一次成功啟動」的標記為 0。
- **作用：** 告訴 Bootloader，上一次啟動並不被視為「完全成功」。這通常會觸發系統的自檢或嘗試切換到備用分區。
  `hello`


 `nvram set flag_boot_rootfs=0`

- **意義：** 指定啟動的根文件系統（Rootfs）分區編號為 **0**。

- **作用：** 這是最關鍵的一步。小米路由器通常有 `rootfs0` 和 `rootfs1` 兩個分區。

  - 設置為 `0`：強制下次重啟進入 **第一分區**。
  - 設置為 `1`：強制下次重啟進入 **第二分區**。

  

**結果：** 設置 `flag_boot_success=1` 強制它停留在你刷好的那個分區。









| **組合**     | **flag_boot_success** | **flag_last_success** | **啟動結果**                                                 | **適用場景**                                        |
| ------------ | --------------------- | --------------------- | ------------------------------------------------------------ | --------------------------------------------------- |
| **正常模式** | **1**                 | **1**                 | **直接引導**：從當前 `flag_boot_rootfs` 指定的分區正常啟動。 | 日常穩定運行狀態。                                  |
| **強制模式** | **1**                 | **0**                 | **強行引導**：無視之前的啟動失敗記錄，強行嘗試從當前分區引導。 | **刷 OpenWrt 後第一次重啟必用**，防止自動跳回原廠。 |
| **失敗模式** | **0**                 | **0**                 | **切換分區**：系統認為當前分區損壞，會嘗試切換到另一個 Rootfs（0 變 1，1 變 0）。 | 手動想切換回另一個系統（如原廠救磚）。              |
| **計數模式** | **0**                 | **1**                 | **待定狀態**：會增加 `boot_count` 計數。如果多次不成功，最終會進入修復模式。 | 系統異常關機後的自動行為。                          |







### 刷機步驟



第一步：解锁SSH，https://miwifi.dev/ssh 輸入SN序列號，telnet 192.168.31.1 root 輸入密碼90jjjjs `passwd`修改密碼

第二步：刷入临时xiaomimtd12.bin固件
（必须是在mtd13分区下向mtd12分区刷入临时固件）

1. 首先检查当前启动系统所在分区
       nvram get flag_last_success
   返回数字1（13分区）那没事了继续. 若返回0，就得按之前刷入op的方法向13分区刷入op然后设置下次启动13分区然后继续
   （别直接改下次启动13，怕13分区没系统或者op不合适直接转）（当然这时没改分区表，砖了用小米官方救砖）

2. 使用ssh把临时固件“xiaomimtd12.bin”上传到路由器tmp目录，

  3.（设置启动分区mtd12，别重启）
    登录ssh，输入下面的命令，将启动分区设置为0（即mtd12 rootfs）
     nvram set flag_last_success=0
     nvram set flag_boot_rootfs=0
     nvram commit

4. （刷入固件到12分区，然后重启）
       输入mtd write redmi_ax6_mtd12.bin rootfs 刷入xiaomimtd12.bin固件到名为rootfs的12分区，
       输入 reboot 重启路由器，
       稍候片刻在浏览器中输入192.168.1.1，打开登录页面表示重启完毕。
     （不要通过路由器指示灯判断是否启动完毕，刷入临时固件后指示灯一直处于熄灭状态）





~~~
root@XiaoQiang:~# nvram show|grep boot
bootcmd=tftp
bootdelay=5
boot_wait=off
flag_boot_rootfs=0
flag_boot_type=2
flag_ota_reboot=0
flag_boot_success=1
root@XiaoQiang:~# 
root@XiaoQiang:~# 
root@XiaoQiang:~# 
root@XiaoQiang:~# nvram show|grep last
flag_last_success=0
root@XiaoQiang:~# 
root@XiaoQiang:~# 
root@XiaoQiang:~# 


nvram set flag_last_success=0
nvram set flag_boot_rootfs=1
nvram set flag_boot_success=1
nvram commit

#下面這個可以，強制啟動道rootfs1
nvram set flag_last_success=1
nvram set flag_boot_rootfs=1
nvram set flag_boot_success=1
nvram commit


#下面這個可以，強制啟動道rootfs0
nvram set flag_last_success=0
nvram set flag_boot_rootfs=0
nvram set flag_boot_success=1
nvram commit


scp xxx@192.168.31.156:/Users/xxx/w/d/xiaomi/new/redmi_ax6_mtd12.bin .


nvram show



mtd write mtd13_rootfs1.bin rootfs_1
~~~









5. 改完分区表，拔电源，然后按住reset按钮插电源，直接进入uboot引导刷机（因为合并完现在没系统）

~~~

 mtd write ax6-mibib-stock.bin /dev/mtd1

 mtd verify   ax6-mibib-stock.bin /dev/mtd1

 #擦除mtd7，刷入改版uboot

 mtd write ax6-uboot-stock.bin /dev/mtd7

 mtd verify  ax6-uboot-stock.bin /dev/mtd7


~~~







主要參考

https://www.right.com.cn/forum/forum.php?mod=viewthread&tid=8378593&extra=page%3D1&page=1

https://www.right.com.cn/forum/forum.php?mod=viewthread&tid=8426229&extra=page%3D1&page=1

https://github.com/fightroad/AX6-OpenWRT

https://github.com/VIKINGYFY/immortalwrt