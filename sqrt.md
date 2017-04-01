卡马克平方根倒数算法
--------------------

https://zh.wikipedia.org/wiki/%E5%B9%B3%E6%96%B9%E6%A0%B9%E5%80%92%E6%95%B0%E9%80%9F%E7%AE%97%E6%B3%95

Common Lisp:

```lisp
(use-package :sb-alien)

(defun csqrt (x)
  (if (< x 0)
      (error "CSQRT: X<0!"))
  (let* ((threefalfs 1.5)
         (x2 (* 0.5 x))
         (y (* 1.0 x))
         (i (make-alien float)))
    (setf (deref i) y)
    (setf (deref (cast i (* int)))
          (- #x5f3759df (ash (deref (cast i (* int))) -1)))
    (setf y (deref i))
    (setf y (* y (- threefalfs (* x2 y y))))
    (setf y (* y (- threefalfs (* x2 y y))))
    (free-alien i)
    (/ 1 y)))

(csqrt 8100)
```

Python:

```Python
from ctypes import *

def nsqrt(x): # do not change the heading of the function
    # carmack square root
    if(x<0):
        raise ValueError("math domain error")
    threefalfs = 1.5
    x2 = 0.5 * x
    y = 1.0 * x
    i = cast(pointer(c_float(y)), POINTER(c_int32)).contents.value
    i  = 0x5f3759df - ( i >> 1 )
    y = cast(pointer(c_int32(i)), POINTER(c_float)).contents.value
    y = y * (threefalfs - (x2 * y * y))
    y = y * (threefalfs - (x2 * y * y))
    return 1 / y
```

我是有多无聊……
