ChatGPT现状
ChatGPT目前封锁了绝大多数的数据中心IP，倘若你现在正好在使用vps作为主力代理，那么应该会在ChatGPT首页看到无法使用的封锁消息！

如何解决
首先，为了更稳定的使用ChatGPT服务，你可以尝试选用原生IP的vps服务商，推荐：66云 和莱卡云

另外，你可以选用ISP的机场：飞瓜云（TVV和美国是ISP）正常使用GPT其他节点是解锁流媒体；

第三个方法，使用vps+ChatGPT-web自己搭建GPT网页版，参考GitHub：https://github.com/Chanzhaoyu/chatgpt-web ，更容易使用的有：https://github.com/Niek/chatgpt-web 等等！

现在，又有了一个新的方法，就是用warp解锁GPT，说到warp我们并不陌生，早期大家都用它来解锁流媒体服务，现在它又有了新的使命：

warp是什么
warp.png

这里我引用作者的主页内容：https://github.com/fscarmen/warp

支持 chatGPT，解锁奈飞流媒体
避免 Google 验证码或是使用 Google 学术搜索
可调用 IPv4 接口，使青龙和V2P等项目能正常运行
由于可以双向转输数据，能做对方VPS的跳板和探针，替代 HE tunnelbroker
能让 IPv6 only VPS 上做的节点支持 Telegram
IPv6 建的节点能在只支持 IPv4 的 PassWall、ShadowSocksR Plus+ 上使用

没看明白？
你可以理解为给你的服务器添加了原生ipv4或者IPv6，这就简单多了！

如何使用warp
网上流行的warp的几个版本包括：

https://github.com/fscarmen/warp
https://github.com/P3TERX/warp.sh
https://gitlab.com/ProjectWARP/warp-go/-/tree/master/
https://github.com/yonggekkk/warp-yg
https://gitlab.com/Misaka-blog/warp-script

这些脚本都可以轻松实现上面的功能，本次我们以 https://github.com/fscarmen/warp 为例进行演示。

1、首次运行

wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh [option] [lisence]
2、再次运行

warp [option] [lisence]
3、参数参考github主页，我这里来一个极简演示：

wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh 4
写在最后
OpenAI-检查器项目：https://github.com/missuo/OpenAI-Checker

一件脚本检查：

bash <(curl -Ls https://cpp.li/openai)
视频教程：
YouTube：https://www.youtube.com/watch?v=ZEdgK4SWBEI

