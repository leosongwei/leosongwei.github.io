CL-JSON的编码问题
-----------------

tags: common lisp; json; cl-json; bug; unicode; Surrogate Pairs;

拿Common Lisp给IRC频道和Telegram群写传话Bot。想要支持表情功能，结果发现提取表情的字符串后，解码错误，搞了好久没搞定，真是扫兴。最后发现问题处在CL-JSON这个库上，那个库的decoder.lisp文件中，解析“\u”转义序列的代码是这样的：

```lisp
((len rdx)
 (let ((code
        (let ((repr (make-string len)))
          (dotimes (i len)
            (setf (aref repr i) (read-char stream)))
          (handler-case (parse-integer repr :radix rdx)
            (parse-error ()
              (json-syntax-error stream esc-error-fmt
                                 (format nil "\\~C" c)
                                 repr))))))
   (restart-case
       (or (and (< code char-code-limit) (code-char code))
           (error 'no-char-for-code :code code))
...
...
```

显然，这里没有实现Surrogate Pairs，所以被编码成`"\ud83d\ude03"`形式的Emoji表情会被劈成2个字符分别读取，对Lisp来说，就变成乱码了。改天有空给他们修一修，先来个Dirty Hack。

设`xxx`对于SBCL来说是Surrogate Pairs的两个字符（这时bug已经发生了，我们将错就错），如此可以得到原字符：

```lisp
(progn
  (setf xxx (with-input-from-string (stream "\"\\uD83D\\uDE03\"")
              (cl-json:decode-json stream)))

  (princ (code-char
          (let ((c1 (char-code (aref xxx 0)))
                (c2 (char-code (aref xxx 1))))
            (+ #x10000
               (ash (logand #x03FF c1) 10)
               (logand #x03FF c2))))))
```

输出是：
```
😃
#\SMILING_FACE_WITH_OPEN_MOUTH
```
