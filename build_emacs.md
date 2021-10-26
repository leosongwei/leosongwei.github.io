Build Emacs
-----------

tags: emacs; build;

Adapted from Debian's config.

```
./configure --build x86_64-linux-gnu --prefix=/opt/emacs --with-native-compilation --with-sound=alsa --without-gconf --with-cairo --with-x=yes --with-x-toolkit=gtk3 --with-toolkit-scroll-bars 'CFLAGS=-g -O2' 'CPPFLAGS=-Wdate-time -D_FORTIFY_SOURCE=2' LDFLAGS=-Wl,-z,relro
```
