Common Lisp动态作用域
---------------------

tags: common lisp; lisp; scope; dynamic scope;

看来，Common Lisp的动态作用域一旦开了线程是不跟着代码走的。

```lisp
(defvar *g1* :x)
(defvar *out* *standard-output*)

(defun pg1 ()
  (format *out* "~A~%" *g1*))

(progn
  (pg1)
  (let ((*g1* :aaaa))
    (pg1)
    (sb-thread:make-thread
     (lambda ()
       (format *out* "---~%")
       (pg1)
       (format *out* "---~%")))))
```

输出：

```lisp
X
AAAA
---
X
---
```
