modprobe blacklist bluetooth
-----------------------------

tag: modprobe; blacklist; bluetooth

`/etc/modprobe.d/nobluetooth.conf`:

```
blacklist btusb
```

Blacklisting the module `bluetooth` will not be effective, because `btusb` will load the `bluetooth` module.
