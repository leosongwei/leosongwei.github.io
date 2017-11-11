在Markdown里面无脑高亮LaTeX语法
-------------------------------

tags: latex, vim, markdown

```
syn match  texCmd               "\\\w*" nextgroup=texBrace,texBeginEndModifier
syn region texBrace		matchgroup=latexcmd	start="{"		end="}"	contains=texBrace,texCmd
"syn match  texBeginEnd		\"\\begin\>\|\\end\>" contained nextgroup=texBeginEndName
syn region texBeginEnd          matchgroup=latexcmd     start="\\begin"         end="\\end" contains=texBrace,texCmd
syn region texBeginEndName	matchgroup=latexcmd	start="{"		end="}"	contained contains=texBrace	nextgroup=texBeginEndModifier
syn region texBeginEndModifier	matchgroup=latexcmd	start="\["		end="]"	contained nextgroup=texBrace
```
