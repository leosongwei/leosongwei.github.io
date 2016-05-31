Maximus
=======

TAG: Gnome3; Gnome Shell; maximus; Window Manager; Decorator; Title Bar; 标题栏; Maximize Window; 最大化;

“众所周知”Gnome3是一个为平板电脑设计的桌面环境，虽然并没有多少平板电脑实际支持它。由于他们人很多，所以它现在也是Linux上最好的、最稳定的桌面环境之一。

相比之下，新KDE的稳定性实在是不敢恭维：运转一段时间后会出现死循环，用去很多CPU时间，使得电脑变得烫烫的，用起来卡卡的，CPU风扇吵吵的。KDE社区有个陈年老帖，就是说某人遇到了这个问题。一开始似乎还能够修复这个问题，结果，后来跟贴的人越来越多，从14年发，到16年还有人回复说也有类似症状，原因也是千奇百怪……[1]

是以我不得不用Gnome。Gnome Shell有很多匪夷所思的设计，比如巨大的标题栏，以及明明应该做到右上角却藏在左下角的通知区域。

然后我在Arch的Wiki里面查到了maximus。maximus是一个迷之程序，能将最大化窗口的装饰去掉，完美符合我所需要的效果：这样一来，最大化窗口的标题栏就消失了。

我用Debian Testing，官方源里面有，apt install maximus就能装。ArchLinux则在AUR里面。[2]

[1] plasmashell high CPU load https://forum.kde.org/viewtopic.php?f=289&t=121533&start=45
[2] Package Details: maximus 0.4.14-6 https://aur.archlinux.org/packages/maximus/
