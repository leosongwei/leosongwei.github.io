(slide
 (body
  (br) (br)
  (body "     " (c yellow (b(hi "(Lisp 与 S表达式)"))))
  (br)
  (br)
  (br)
  (br)
  (br)
  (br)
  (brer "                        凉拌茶叶"
        "                        CDLUG 2016年8月活动"
        (br)
        "                        (Made with cl-slider)")))

(slide
 (body
  (b (hi "目录")) (br) (br)
  (brer (hi(b "* 初识Lisp"))
        "* S表达式入门"
        "* ”Lisp没有语法“"
        "* 面向语言编程")))

(slide
 (body
  (b (hi "初识Lisp")) (br) (br)
  (brer "印象："
        "* 古怪的语言"
        "* 括号太多")))

(slide
 (body
  (b (hi "初识Lisp")) (br) (br)
"几种数据类型：
* 符号
* 序对(pair/cons)
* 数字
* 函数"))

(slide
 (body
  (b (hi "初识Lisp")) (br) (br)
  (brer
"基本操作："
(body "* " (c red (b "黑暗原力")) "：eq, eql, equal")
"  - (eq 'a 'b)
* quote与单引号
  - 'a ≡ (quote a)"
(b "* cons, car, cdr")
"* (lambda (a b c)
    (do-something))")))

(slide
 (body
  (b (hi "初识Lisp")) (br) (br)
"求值规则：
* 前缀表示法：(function arg1 arg2 arg3 ...)
  - (+ 1 2 (* 3 4)) ≡ 1 + 2 + 3 * 4
* 以括号中的第一项为函数进行调用
* 后面的都是参数" (br)
(b "* 然而部分实现并不保证求值顺序")))

(slide
 (body
  (b (hi "目录")) (br) (br)
  (brer "* 初识Lisp"
        (hi(b "* S表达式入门"))
        "* ”Lisp没有语法“"
        "* 面向语言编程")))

(slide
 (body
  (b (hi "S表达式入门")) (br) (br)
"* S表达式是一种树状表示法
   - 例：对比HTML和S表达式"))

(slide
 (body
  (b (hi "S表达式入门")) (br) (br)
"<html>
  <head>
    <title>test page</title>
  </head>
  <body>
    <div class=\"body\">
      <h1>test page</h1>
      <p>this <b>page</b> is for test</p>
    </div>
  </body>
</html>"))

(slide
 (body
  (b (hi "S表达式入门")) (br) (br)
"(html
 (head
  (title \"test page\"))
 (body
  (div :class \"body\"
       (h1 \"test page\")
       (p \"this \" (b \"page\") \" is for test\"))))"))

(slide
 (body
  (b (hi "S表达式入门")) (br) (br)
"* S表达式是Lisp中”表“的表示法
* ”表“在Lisp中由基本数据类型" (b "序对") "(cons/pair)拼接而成

  [ . | . ]
    ↓   ↓    (cons 'a 'b) ≡ (A . B)
   'A  'B

  [ . |NIL]
    ↓        (cons 'a nil) ≡ (A)
   'A"))

(slide
 (body
  (b (hi "S表达式入门")) (br) (br)
"* CAR/CDR
  - CAR：取出序对的第一个元素 (car '(a . b)) → A
  - CDR：取出序对的第二个元素 (cdr '(a . b)) → B
* 列表
  - CAR：取出列表的头一个元素 (car '(a b c)) → A
  - CDR：取出列表的剩余部分 (cdr '(a b c)) → (B C)"))

(slide
 (body
  (b (hi "S表达式入门")) (br) (br)
"* ”CONS“的黑历史：
  - IBM704计算机的字长为36位，地址长15位
  - 有机器指令将字分为四段
  - Address(15), Prefix(3), Decrement(15), Tag(3)
  - CAR: “Contents of the Address part of Register number”
  - 这很”汇编“"))

(slide
 (body
  (b (hi "目录")) (br) (br)
  (brer "* 初识Lisp"
        "* S表达式入门"
        (hi(b "* “Lisp没有语法”"))
        "* 面向语言编程")))

(slide
 (body
  (b (hi "“Lisp没有语法”")) (br) (br)
"* Lisp程序员在抽象语法树（AST）上编程


* Lisp程序在读入后以“表”的形式表示和存储"))

(slide
 (body
  (b (hi "“Lisp没有语法”")) (br) (br)
"* Lisp程序员在抽象语法树（AST）上编程
  - Lisp“没有”奇怪的限制

* Lisp程序在读入后以“表”的形式表示和存储
  - Lisp程序可以写Lisp程序（宏）"))

(slide
 (body
  (b (hi "“Lisp没有语法”")) (br) (br)
"* 奇怪的限制（C语言）

 printf(\"％d\", if(10==20){
		   	printf(\"233\");
			return 10;
		 }else{
			return 20;
		 });"))

(slide
 (body
  (b (hi "“Lisp没有语法”")) (br) (br)
"* 又是奇怪的限制（JavaScript）

  console.log(if(1==10){
	console.log(1);
  }else{
	console.log(2);
  });

* kosmos同学提出了一个workaround：用匿名函数"))

(slide
 (body
  (b (hi "“Lisp没有语法”")) (br) (br)
"* 没有奇怪的限制

(let ((v 'a))
  (format t \"V(~A) is ~Aa symbol~%\"
          v
          (if (symbolp v)
              \"\"
              \"not \")))"))

(slide
 (body
  (b (hi "“Lisp没有语法”：初窥Lisp宏")) (br) (br)
"* Lisp程序在读入后以“表”的形式表示和存储
  - Lisp程序可以写Lisp程序（宏）

* Lisp的宏是挂在编译器上的函数
  - 读入列表，吐出列表
  - 在编译之前将表达式展开
  - 宏就是写Lisp程序的程序"))

(slide
 (body
  (b (hi "“Lisp没有语法”：初窥Lisp宏")) (br) (br)
"* C语言的宏贯彻Unix哲学：一切皆字符串
  - C语言的宏是基于字符替换的

* Lisp的宏更加强大：
  - Lisp程序可以用Lisp的列表来表示
  - 你可以用Lisp进行编程，修改这些列表"))

(slide
 (body
  (b (hi "“Lisp没有语法”：初窥Lisp宏")) (br) (br)
"例：利用宏来“扭曲”传参规则

(defmacro setf-square-attrib (X Y)
  `(progn (setf x ,X)
          (setf y ,Y)
          (setf area (* ,x ,y))))

(let (x y area)
  (setf-square-attrib 20 40)
  (list :x x :y y :area area))
→ (:X 20 :Y 40 :AREA 800)"))

(slide
 (body
  (b (hi "“Lisp没有语法”：初窥Lisp宏")) (br) (br)
  (b "宏的写法") (br) (br)
"* 宏就是一个返回列表的函数
* 反括号
  - 阻止求值，表示列表的简记号，类似于单引号
  - 可以用“,”与“,@”恢复求值
    - ,：直接将返回的列表插入原来的位置
    - ,@：将返回的列表展开，插入原来的位置"))

(slide
 (body
  (b (hi "“Lisp没有语法”：初窥Lisp宏")) (br) (br)
"反括号的示例：

(let (x y area)
  (setf-square-attrib 20 40)
  `(:x ,x :y ,y :area ,area))
→ (:X 20 :Y 40 :AREA 800)"))

(slide
 (body
  (b (hi "目录")) (br) (br)
  (brer "* 初识Lisp"
        "* S表达式入门"
        "* “Lisp没有语法”"
        (c yellow (hi(b"* 面向语言编程"))))))

(slide
 (body
  (b (hi "面向语言编程")) (br) (br)
"* 引入自己的语义

(defins PUSH
  \"PUSH -. (VAL)
   VAL -> PS[]\"
  (setf (aref *stack* *PS*) (car *val*))
  (incf *PS*)
  (setf (aref *stack* *PS*) (cdr *val*))
  (incf *PS*))"))

(slide
 (body
  (b (hi "面向语言编程")) (br) (br)
"* 记载数据和配置
(defsystem uffi
  :name \"uffi\"
  ...
  :components
  ((:module :src
	    :components
	    ((:file \"package\")
             (:file \"i18n\" :depends-on (\"package\"))
	     (:file \"primitives\" :depends-on (\"i18n\"))...
（用ASDF定义的包uffi）"))

(slide
 (body
  (b (hi "面向语言编程")) (br)
"* 当作模板
(define (render-blog-page a-blog request)
  (response/xexpr
   `(html (head (title \"My Blog\"))
          (body
           (h1 \"My Blog\")
           ,(render-posts a-blog)
           (form
            (input ((name \"title\")))
            (input ((name \"body\")))
            (input ((type \"submit\"))))))))
（Racket教程）"))

(slide
 (body
  (b (hi "面向语言编程")) (br) (br)
"* 表示别的语言
...
  (inst lea ebx (make-ea :dword :base ebp-tn
                         :disp (* sp->fp-offset n-word-bytes)))
  (inst mov edx nil-value)
  (inst mov edi edx)
  (inst mov esi edx)
  (inst mov esp-tn ebp-tn)
...
（SBCL源代码）"))

(slide
 (body
  (b (hi "面向语言编程")) (br)
  (c yellow (b "拆解cl-slider")) (br) (br)
"* ncurses提供的基本操作：
  - wprintw
  - attron/attroff
* 要用到的功能：
  - 加粗
  - 高亮
  - 下划线
  - 色彩"))

(slide
 (body
  (b (hi "面向语言编程")) (br)
  (c yellow (b "拆解cl-slider")) (br) (br)
"* 写了两个基本的操作：
  - with-attr：自动应用、还原样式
  - with-color：自动应用、还原颜色
* 例：
(with-color red
  (wprintw \"hello\")
  (with-attr (reverse bold)
    (wprintw \"test\"))
  (wprintw \"world\"))" (br) (br)
"效果: " (c red "hello" (hi(b "test")) "world")))

(slide
 (body
  (b (hi "面向语言编程")) (br)
  (c yellow (b "拆解cl-slider")) (br) (br)
"* 写一套东西，把DSL转换成这种形式运行就可以了
* DSL:
  (c red \"hello\" (hi (b \"test\")) \"world\")
* 流程：
  1. 读取DSL，使它变成S表达式
  2. 递归处理之，生成可执行的代码
    - 由于缺乏睡眠，还绕了个远路
  3. 把生成的代码套到一层lambda中，用eval命令编译成一个函数
  4. 执行这个函数，绘制幻灯片"))

(slide
 (body
  (b (hi "面向语言编程")) (br)
  (c yellow (b "拆解cl-slider")) (br) (br)
"* 生成的可执行代码：
(PROGN
 (PUSH COLOR-CURRENT COLOR-STACK)
 (SETF COLOR-CURRENT COLOR_RED)
 (ATTRON (COLOR-PAIR COLOR-CURRENT))
 (LET ((#:G573 (CONVERT-TO-CSTRING \"hello\")))
   (WPRINTW *STDSCR* #:G573)
   (FREE-CSTRING #:G573))
 (PROGN
  (PUSH (COPY-AS AS-CURRENT) AS-STACK)
  (LET ((#:G576 (MAKE-AS)))
    (SET-AS #:G576 '(REVERSE)) ..."))

(slide
  (body
   (br)
   (br)
   (br)
   "          " (b "结束，谢谢") (br)
   (br)
   (br)
   (br)
   (br)
   "                      " (u "接下来是吹水环节")))
