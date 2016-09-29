Common Lisp Keywords
====================

tags: common lisp; lisp; keyword;

之前不仔细，现在才发现Common Lisp里面有一种叫做keyword的东西。

keyword就是以冒号开头的符号，它们会直接导入到keyword包中。根据The Hyper Spec里面的描述，创建一个keyword会有以下三个影响：

1. 使得它的被绑定到它自己，自求值。
2. 对于KEYWORD包，这个符号被设置成一个导出的符号。
3. 这个符号被设定为一个常量。

在SBCL里面跑了一下ANSI Common Lisp的例子，若是不写成keyword，在测试包中正常执行的函数，在包外面执行的时候就坑了：

```lisp
CL-USER> 
;;; from test.lisp
CL-USER> (defpackage test1
  (:use cl-user cl))
#<PACKAGE "TEST1">
CL-USER> 
;;; from test.lisp
CL-USER> (in-package test1)
#<PACKAGE "TEST1">
TEST1> 
;;; from test.lisp
TEST1> (defun noise (animal)
  (case animal
    (:dog :woof)
    (:cat :meow)
    (:pig :oink)))
WARNING: redefining TEST1::NOISE in DEFUN
NOISE
TEST1> 
;;; from test.lisp
TEST1> (defun noise1 (animal)
  (case animal
    (dog 'woof)
    (cat 'meow)
    (pig 'oink)))
WARNING: redefining TEST1::NOISE1 in DEFUN
NOISE1
TEST1> (noise :cat)
:MEOW
TEST1> (noise1 'cat)
MEOW
TEST1> 
;;; from test.lisp
TEST1> (in-package cl-user)
#<PACKAGE "COMMON-LISP-USER">
CL-USER> (TEST1::NOISE :cat)
:MEOW
CL-USER> (TEST1::NOISE1 'cat)
NIL
CL-USER> 
```

Common Lisp这玩意儿坑还真多。
