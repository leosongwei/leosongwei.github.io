LXC
===

因为上课要用到奇怪的软件，又不想一股脑安装到主系统上，便萌生了尝试容器的想法。之前尝试过Docker，但是docker比较奇怪，各种教程都喜欢让人下载镜像，尝试过自行构建却没有成功，遂放弃。

这次发现lxc比docker更加直抒胸臆，比如要安装Debian，就拿debootstrap下载软件包，现场捏一个debian出来，而不是像docker那样从奇怪的来源下载镜像（虽然有点发行版官方是有镜像的），非常易于理解。

笔记部分
--------

* 安装Ubuntu
	* ArchLinux这个lxc，直接用template安装，会安装古老的12.04，所以要加参数。Debian则会直接安装Jessie。
	* `# lxc-create -n ubuntu -t /usr/share/lxc/templates/lxc-ubuntu -- -r xenial -a amd64`
