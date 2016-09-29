Systemd关机超时设置
-------------------

tags: systemd; linux; very slow;

Linux的USB存储设备驱动是有许多问题的，很多时候拔掉移动硬盘、U盘后，系统还以为它们是插着的，好像并不会超时，总之就是死掉了。然而Systemd的超时时间设定得特别长，看到Linux关机时systemd不断提示说还有任务没执行完，等待90秒的时候，感觉就像重启Windows，发现要更新30分钟一样。

改这个文件：`/etc/systemd/system.conf`，把里面的`DefaultTimeoutStopSec`设定成15秒就行了，反正笔记本上没什么重要数据。

每次我重装系统后，都要搜索这个参数，谷歌又反应不过来，是以写了这么一篇博客来记录。
