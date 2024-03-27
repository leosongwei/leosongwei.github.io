Nvidia，KDE与Wayland
--------------------

tags: Linux; KDE; NVIDIA; wayland; Firefox; zink; Electron

笔记性质，我用Debian，KDE5，也许不适合于其它发行版和KDE版本。成文于2024年初，你看到时也许过时了。

## 手工安装N卡驱动与开源内核模块

### EGL

刚装的系统，直接装NVIDIA提供的run文件当然会炸，因为可能缺乏pkg-config，需要先：

`sudo apt install pkg-config libglvnd-dev`

### 安装驱动与开源内核模块

如果已经手工安装N卡驱动，需要删除之：

`# nvidia-uninstall`

安装：

`# sh ./NVIDIA-Linux-[...].run -m=kernel-open`

参考[NVIDIA的README](http://download.nvidia.com/XFree86/Linux-x86_64/535.54.03/README/kernel_open.html)

## KDE与wayland

`sudo apt install plasma-workspace-wayland`

### Firefox

`MOZ_ENABLE_WAYLAND=1 firefox`

在about:config中设置: `layout.css.devPixelsPerPx`

### Chromium和Electron应用闪烁

加上选项：`--enable-features=UseOzonePlatform --ozone-platform=wayland`
  * `--ozone-platform=x11`似乎好用些

这个Ozone是Chromium自己的玩意儿：

> Ozone is a platform abstraction layer beneath the Aura window system that is used for low level input and graphics

https://chromium.googlesource.com/chromium/src/+/HEAD/docs/ozone_overview.md

### Electron输入法

https://bbs.archlinuxcn.org/viewtopic.php?id=13291

### wayland缺egl包

`apt install libnvidia-egl-wayland-dev`

### Nvidia modset

`/etc/default/grub`中设置：

`GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1"`

### 缩放与糊

KDE似乎需要设置什么环境变量，缩放才不会糊，不过似乎很痛苦，我用4K屏就简单处理了，用2K屏的伙伴们应该有得罪受了。

* 直接设置缩放200%会糊
* “字体”里面调DPI可以解决，图标也会缩放

### Steam Debug

也许和KDE+wayland无关，但你用这个组合的时候发现游戏打不开应该是非常绝望的。

要debug可以在游戏->属性->通用->启动选项中设置log：

`PROTON_LOG=1 %command%`

会在home目录中创建一个形如：steam-476530.log的log文件

### 在KDE中添加环境变量

参考：https://community.kde.org/KWin/Environment_Variables

在`~/.config/plasma-workspace/env/`中创建一个.sh文件即可

## 已知bug，历史bug

* 5.24版KDE（大概2021年的版本，见于Ubuntu 22.04）在wayland上有有关剪切板的致命bug，开起`nvidia_drm.modeset`后面板会严重卡顿，dolphin删除文件时会卡死
* 任务栏小工具`任务管理器`可能卡死，改用`图标任务管理器`。也有说法说禁用任务管理器的鼠标悬浮预览可以解决问题。来源： https://www.reddit.com/r/kde/comments/snhb2c/kde_panel_plasma_frozen_what_to_try/ 

### kwin on Zink

是的，可以这么玩，没啥用，应该会更卡，也许会变快，都是心理作用（也算是证明zink如今基本可用了）。

构建包含zink的mesa，注意我这里给它装到了一个别的地方，你最好也这样做：

```
meson setup builddir/ -Dprefix="$MESA_INSTALLDIR" -Dgallium-drivers=swrast,virgl,zink,freedreno
```

用编译好的mesa启动minecraft：

```
LD_LIBRARY_PATH=$MESA_INSTALLDIR/lib/x86_64-linux-gnu __GLX_VENDOR_LIBRARY_NAME=mesa MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink minecraft-launcher
```

然后让KDE用上它，这个办法比较干净，不会让kwin以外的东西用上zink，请读者酌情参考。

用你自己的用户执行：

`$ systemctl --user edit plasma-kwin_wayland.service`

加入：

```
[Service]
Environment=LD_LIBRARY_PATH=/opt/mesa-23.2rc1/lib/x86_64-linux-gnu
Environment=__GLX_VENDOR_LIBRARY_NAME=mesa
Environment=MESA_LOADER_DRIVER_OVERRIDE=zink
Environment=GALLIUM_DRIVER=zink
```

注意这个user unit是添加到原来的设置中的，所以不需要重复整个文件

启动后去mesa目录下lsof，可见该libGL正被kwin使用：

```
/opt/mesa-23.2rc1/lib/x86_64-linux-gnu$ lsof *
COMMAND	PID USER  FD   TYPE DEVICE SIZE/OFF  	NODE NAME
kwin_wayl 1327  leo mem	REG   8,18   321192 269679515 libglapi.so.0.0.0
kwin_wayl 1327  leo mem	REG   8,18  2742440 269679506 libGL.so.1.2.0
```
