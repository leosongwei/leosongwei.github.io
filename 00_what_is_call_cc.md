What is CALL/CC?
================

TAG: #LISP #Scheme

Scheme把续延当作第一级类型来对待。要理解call/cc如何使用，首先需要理解概念“续延”（Continuation）。任何的计算，都有一个续延，即那个在等待该计算的值的东西。

如式子`(+ 1 (+ 2 3))`中的计算`(+ 2 3)`的续延为`(+ 1 [])`，其中的“[]”指`(+ 2 3)`的值所要填进去的地方。若是写成调用栈的形式，就应该是这样：

```scheme
1. (+ 2 3)
0. (+ 1 [])
```

可以明显地看出，要完成第0层的计算，需要第1层的计算结果。而且，可以把第0层看作是一个类似于函数的东西，它“等待”一个值（接受一个参数）来完成计算。如此一来，我们便可以把续延以类似函数的形式保留下来，并能像函数一样调用（然而并不完全一样）。

观察下面的代码和计算结果：

```scheme
(define *k* '())

(define (f)
  (+ 33 (call/cc
	 (lambda (k)
	   (set! *k* k)
	   200))))

1. (f) => 233
2. (*k* 2200) => 2233
3. (+ 666 (*k* 1000)) => 1033
```

call/cc接受一个函数（这个函数只接受1个参数），call/cc立即调用这个函数，把当前的续延作为参数传给这个函数（R6RS把这个参数称为“Escape Procedure”）。[[1]](#[1])这个函数的执行结果（200）被作为计算的结果传送给续延`(+ 33 [])`，所以计算1的计算结果是233。

其中，我保存了这个续延，所以可以在函数执行结束后继续使用这个续延。现在观察计算2，我们喂给续延一个值（2200），`(+ 33 [])`就计算出了2233。

计算3是比较有趣的地方，我们发现，计算`(*k* 1000)`的续延`(+ 666 [])`并没有执行。在Scheme中，调用一个续延时，计算就丢掉了自己的续延（可以理解成整个栈被替换了，确实可以这么实现）。所以我们得到值1033。

示例，当作“Return”来使用：

递归查找一个表中是否有某个符号，找到了就返回符号的“位置”。

```scheme
(define call/cc call-with-current-continuation)

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

### TCO（Tail Call Optimization）

理解了“续延”，就能理解TCO（尾调用优化）了。

我们可以想像一个无穷递归的函数：

```CommonLisp
(defun have-a-good-idea ()
  (found-a-company)
  (fail)
  (have-a-good-idea))
```

不做任何处理，若你“创业并失败”的速度足够快，因为每次你有一个伟大的点子就要新建一个栈帧，很快栈就耗尽了。很多场合，写递归有一定优势（如更好的可读性，方便用数学归纳法证明等），然而当数据量很大时（或是我们需要它无穷循环时），就很容易把栈耗尽。按照“常识”，我们就应该少用递归。

但是程序语言为什么要保存所有的栈帧呢？有没有我们可以不维持这么多栈帧的情况呢？有的，观察这个`have-a-good-idea`函数，对于计算：

```CommonLisp
(think (have-a-good-idea))
```

其中，每一层`have-a-good-idea`的续延都是上一层的`have-a-good-idea`里面的最后一个式子。我们又知道，`defun`定义出来的函数所返回的结果取决于最后一个表达式，即`(have-a-good-idea)`，也就是说，每一层的have-a-good-idea的续延其实都可以往上追溯到这个续延：`(think [])`。因为所有的`(have-a-good-idea)`调用的续延都是一样的，在调用`(have-a-good-idea)`时，就可以每次都把上一级的`(have-a-good-idea)`栈帧毁掉，那么就永远都只有两层栈帧：

```CommonLisp
1. (have-a-good-idea)
0. (think [])
```

这跟循环就没什么区别了，与此同时我们可以享受到递归写法的种种好处。

当我们有很多个不同的函数时，也可以享受到尾递归优化：

``` CommonLisp
(defun a ()
  (do-something)
  (b))

(defun b ()
  (do-something)
  (c))

(defun c ()
  (do-something)
  (d))
...

(abc (a))
```

这个调用链中，我们始终只需要在栈上维持当前函数的栈帧，因为所有函数的续延都是`(abc [])`。

Scheme在标准里面有规定要实现TCO；GCC开-O2有TCO；Java和Clojure没有TCO（所以说Clojure是异端）；Common Lisp的很多实现有TCO，如SBCL有，然而有的实现又没有。CPython没有TCO（知乎上有人说“敢于在 CPython 中大量使用递归是对 CPython 实现的公然侮辱”）。[[2]](#[2])

###引用资料

* <a name="[1]">[1]</a> R6RS http://www.r6rs.org

* <a name="[2]">[2]</a> 怎么样才算是精通 Python？ https://www.zhihu.com/question/19794855
