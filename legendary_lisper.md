笑话一则：Lisp都市传说
----------------------

Tags: Lisp, IRC, Telegram, Joke

我们[MidyMidy MineCraft服务器](https://github.com/MidyMidy-MC/MidyMidyMC-info)，我和TonyChyi充分发扬了这个游戏“Massive Huge Cube Related Chate”（巨硬方块聊天协议）的本质，使得这里更像是一个聊天室而非游戏服务器。

最开始我们有一个IRC的频道，通过Spigot服务器的IRC插件和MineCraft内部的聊天功能相联，而且我们写了脚本来把每天的IRC聊天记录传送到我们的邮件列表，大家过着快乐的生活。

后来有一天，隔壁[喵窝](https://www.nyaa.cat/)发生政治动荡（我并不知道原因），导致一部分抵制的玩家成为了难民，来到了我们的服务器，服主星之光为了接收这些难民，建立了一个Telegram群。这个Telegram群和原来的IRC群之间通过wfjsw编写的Bot“AkarinCentral-T”进行连接。虽然这个Bot功能强大，但是工作不稳定，很容易掉线，时常和Freenode失去连接，需要在Telegram端手动重连。

但是Telegram里面的人不容易知道该Bot的IRC连接断掉了，常常一连几天，IRC都收不到Telegram传来的消息。使我非常不开心，还发过一点小脾气。于是，后来我编写了一个更稳定的[Midymidytgbot](https://github.com/MidyMidy-MC/midymidytgbot)，来取代AkarinCentral-T，这个新Bot用Common Lisp语言编写。Bot需要很多功能，Midymidytgbot是一段新的代码，我也不是太懂IRC和Telegram，也没有““产品经理”来给我规划功能，于是时常需要有些小改动来新增功能，修复bug，修改特性，于是Bot便需要常常重启，显然重启的时候Bot是不工作的，可能漏掉消息。我需要一个打热补丁的姿势。

一天，我和开源哥坐在咖啡馆里写代码，我突然想起了所有介绍Lisp语言的地方都会提到一个故事来说明Lisp的灵活性：传说中的Lisp程序员远程连接到卫星上的Lisp程序上修复了Bug，避免了更大的损失。于是我说：“要不然，我每次就远程连接到服务器上动态地调整代码？”开源哥说：“哈哈哈哈，快醒醒！”

说起来容易，但是问题的背面有一些坑：比如我的服务器上有一些给同学开放的代理服务，通过代理服务是能够访问本地回环的。SLIME（流行的Lisp调试接口）为了兼容非Unix系统（其实就是Windows），把调试端口开在本地回环的4005端口上。同学们的环境非常复杂，有Windows，有安卓，有苹果系列产品，天知道会不会把奇怪的骇客放进我的本地回环（虽然概率很低），导致恶意代码执行。

想到的一个好办法是把SLIME开在一个Unix域套接字上，在SSH上通过[Socket Forward程序](https://github.com/RickyCook/ssh-forward-unix-socket)映射到我本地的一个Unix套接字上，同时解决了加密问题和本地攻击问题。

我觉得因为SLIME是没有加密功能的（为了简洁也不应该有），本来就不应该开放在任意形式的网络中（每次和Windows扯上关系总没好事）。有人去他们的Github Repo发ISSUE请求这个侦听Unix套接字的特性，但维护者显然不喜欢这个特性（有损兼容性），回了一句“为什么需要侦听Unix套接字？”就不理这个ISSUE了。看来，就算是做了这个功能，他们也不会要这些代码的。

综上，我需要自己实现这个功能了。[实现这个功能](https://github.com/leosongwei/slime)倒是没费多大力气，fork一下，改一改就好了（只支持SBCL）。总之，我终于有一个可靠地远程调试途径了，能够用来打热补丁，无需重启服务程序，我觉得非常地开心！

第二天，我发现了Bot的一个小Bug，正好可以测试这个打热补丁的姿势。我高兴地将我的Emacs连上了远端正则运转的Bot，将改好的代码输进了Bot，测试一下运转正常！我就更开心了！此刻，我认为这十分带感：不需要重启，不需要全部重新编译！动态地修改调试运行中的代码！我就像传说中调试太空中的卫星的Lisp程序员一样屌！

工作已经完成，可以退出了！于是我爽快地在SLIME窗口中执行了代码：

```Lisp
(exit)
```

接到我的指令，Bot干净利落地关闭了，于是Bot终于还是没能逃脱要重启的命运……
