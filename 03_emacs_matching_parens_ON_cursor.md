Emacs匹配光标上的括号
=====================

tags: Emacs; Parentheses matching; Cursor;

Emacs很神烦，默认设置下，当你的方块光标指向一个后括号的时候（“)”），它不会匹配光标上的括号，而是会匹配这之前的一个后括号。

实现想Vim一样正确的括号匹配，可以这样做：

```elisp
(show-paren-mode 1)
(setq show-paren-delay 0)
(defun my-show-paren-any (orig-fun)
  (if (looking-at ")")
    (save-excursion (forward-char 1) (funcall orig-fun))
    (funcall orig-fun)))
(add-function :around show-paren-data-function #'my-show-paren-any)
```

代码参考自：http://stackoverflow.com/a/25649189/4516042

原答案在用快捷键移动光标的时候不工作，故修改了一下。
