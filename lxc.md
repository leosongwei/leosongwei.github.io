LXC
===

tags: lxc, ubuntu, login prompt, slow, long waiting, iptables, nat, network;

因为上课要用到奇怪的软件，又不想一股脑安装到主系统上，便萌生了尝试容器的想法。之前尝试过Docker，但是docker比较奇怪，各种教程都喜欢让人下载镜像，尝试过自行构建却没有成功，遂放弃。

这次发现lxc比docker更加直抒胸臆，比如要安装Debian，就拿debootstrap下载软件包，现场捏一个debian出来，而不是像docker那样从奇怪的来源下载镜像（虽然有点发行版官方是有镜像的），非常易于理解。

笔记部分
--------

### 安装Ubuntu

* ArchLinux这个lxc，直接用template安装，会默认安装古老的12.04，所以要加参数
* 加那两横，后面的参数就能给到template了
* `# lxc-create -n ubuntu -t /usr/share/lxc/templates/lxc-ubuntu -- -r xenial -a amd64`
* Ubuntu Server会执着地等待DHCP，所以开机会非常缓慢，无脑调整timeout以修正：
* 改这个文件：`/etc/systemd/system/network-online.targets.wants/networking.service`
* Ubuntu装好后，总会有什么服务来搞乱网络配置，冲洗掉DNS配置，所以要设置resolvconf.conf。Ubuntu搞了一个文件夹来存储配置，然而和man出来的奇怪格式不一样，就按普通的resolv.conf写就是了。

真是不想去当一个Ubuntu专家……

### 其他

* 装Debian则会直接安装Jessie，很和谐，没有特别的故障

* 对于安装路径，我特别懒，就直接把默认的lxc容器目录链接到home盘的一个目录上了

### 网络配置

配置lxc容器使用iptables搭的nat

* 配置网桥

```bash
#!/bin/sh
ip link add name br0 type bridge
ip link set br0 up
ip addr add 192.168.100.1/24 dev br0
```
* 搭NAT
	* `iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE`

* 设置lxc容器的网络（container_dir/config）

```
lxc.network.type = veth
lxc.network.link = br0
lxc.network.flags = up
lxc.network.name = eth0
lxc.network.ipv4 = 192.168.100.10/24
lxc.network.ipv4.gateway = 192.168.100.1
```

后记
----

经过在tjlug的讨论，看起来，docker的设计目标是培养用户使用他们docker hub网站上现成镜像的习惯，然后以这种现成镜像为基础构建自己的、小容量的应用镜像，然后用户自然就会想要用docker hub网站来部署自己的应用镜像，然后docker.com的生意就来了。

而我的需求是轻量化的，类似于虚拟机的东西，自己安装，这和docker.com的业务有所不同。所以我看docker的教程就感觉无比费解，而在lxc-create用debootstrap捏debian的时候，我感觉无比形象。
