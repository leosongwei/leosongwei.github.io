Xephyr
------

tags: Linux; virtual screen; display;

这个东西可以用来提供虚拟显示器（软件渲染）。准确地说是一个nested X server。

装：`xorg-server-xephyr`，然后就可以用了：

`Xephyr -br -ac -noreset -screen 800x600 :1`

把DISPLAY环境变量调好，启动程序即可。

详见：https://wiki.archlinux.org/index.php/Xephyr
