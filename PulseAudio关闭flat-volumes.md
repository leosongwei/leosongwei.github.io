PulseAudio关闭flat-volumes
--------------------------

tags: Linux; Debian; openSUSE; 音量; Volume; PulseAudio;

干货为辅，吐槽为主。

2014年的时候用openSUSE遇到过这个问题，音量难以控制，在播放器中调高音量会影响全局音量。更糟糕的是，系统的提示音始终认为自己的音量是100%，所以一旦出现系统提示音，全局音量将会瞬升至100%，给你震耳欲聋的体验。然而其它任何桌面环境都不会有这个问题。

当时去openSUSE的论坛问了，他们认为不存在这个问题。[1] 这个难以忍受的音量问题和openSUSE糟糕的内核编译（无论他们对自己编译内核的技术的迷之自信到达了怎样的程度，openSUSE的内核在我机器上始终有奇怪的kworker进程，吃掉100%~200%的CPU），以及openSUSE在法律上的懦弱（不敢打包），是我后来转投Debian的直接原因。

后来，到了2016年，我嫌Debian 8的包太老了，安装了Debian Testing，一开始也尝试了KDE，又出现了这个问题。我便四处查询，在KDE的论坛查到了这个东西[2]，简单地说，就是把锅甩给PulseAudio：

在文件`/etc/pulse/daemon.conf`中，设置`flat-volumes = no`。

后来，Debian Testing被GTK3所坑，导致我的MATE无法使用（依赖GTK3），很快，我看微博时发现这个新版Gnome和GTK包含了谷歌编程之夏带来的无数“改进”，又听说Gnome的开发者们又跑了。我就放弃希望，滚回了Debian 8。然后发现Cinamon似乎也有这种状态，不严重（不会出现可怕的系统提示音），但是不方便，今天心血来潮把配置改了一下，发现有用。

-------------------

最近试着用ArchLinux，我看到默认的`flat-volumes = yes`被注释掉了，上面写了一行`flat-volumes = no`，我瞬间感到这位打包者是个常识人，是一个真正的Linux用户。

(16年12月6日)

[1] https://forum.suse.org.cn/viewtopic.php?f=7&t=2475
[2] https://forum.kde.org/viewtopic.php?f=289&t=131535
