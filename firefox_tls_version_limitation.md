Adjust Firefox TLS version limitation
-------------------------------------

tags: firefox; tls; https;

you might see:

> This website might not support the TLS 1.2 protocol, which is the minimum version supported by Firefox.

Please consult: https://support.mozilla.org/en-US/questions/1347751

To temporarily set:

```
security.tls.version.max 1
security.tls.version.min 1
```

date: 2022-08-27
