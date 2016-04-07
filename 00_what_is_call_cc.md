What is CALL/CC?
----------------

TAG: #LISP #Scheme

就是一个跳转机制，下面是一个简单的用法：

递归查找一个表中是否有某个符号，找到了就返回符号的“位置”。

```scheme
(define (test lst id)
  (call/cc
    (lambda (ret)
      (define (check lst)
        (if (pair? lst)
          (if (eq? (car lst) id)
            (ret lst)
            (check (cdr lst)))
          (ret #f)))
      (check lst))))

(user)> (test '(a b c d e f) 'e)
(e f)
```
