NetworkManager Dispatcher
-------------------------

tags: NetworkManager

总是把Wifi作为默认路由的Dispatcher脚本。

放在`/etc/NetworkManager/dispatcher.d`中，用户和组为root，设为可执行。

```bash
#!/usr/bin/bash

# ethernet interface $1
# action $2
interface=$1
action=$2

if [[ $interface == "wlan0" && $action == "up" ]]
then
	gateway=`ip route |grep default|grep wlan0 | sed -r 's/.*via ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/g'`
	$? = 0
	until [[ $? == "2" ]]
	do
		ip route delete default
	done
	sudo ip route add default via $gateway dev wlan0
fi
```
