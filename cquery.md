LSP: cquery和Emacs
------------------

tags: LSP; cquery; Emacs; editor;

最近，想要写一点C语言程序。听开源哥说[LSP（Language Server Protocol）](https://langserver.org/)是个挺好的东西，便搞来用了。原理好像是由统一的语言服务器来解析源码，按照LSP协议和编辑器上的LSP插件通信，来实现如代码补全等功能。每个语言只需要一个LSP服务器，每个编辑器也只需要一个LSP客户端插件（其实一般有多个实现）。这样一来就不需要为每个编辑器分别实现每个语言的语法分析插件，从而得以砸了IDE的锅。

C/C++有个LSP服务器实现，叫[cquery](https://github.com/cquery-project/cquery)，好像是把LLVM怎么包装了一下。ArchLinux的AUR里面有（推荐安装AUR这个cquery-git，若直接从git拉取下来，构建程序会尝试编译整个LLVM，AUR这个就可以使用你电脑里面已经有了的LLVM，不需要下载很多东西，编译速度也很快）。

Emacs上的配置过程大概是：

1. 编译安装cquery这个可执行文件
2. [配置Emacs](https://github.com/cquery-project/cquery/wiki/Emacs)上的插件，除了lsp-mode，还需要cquery自己提供的插件
3. 在源码目录下弄一个`compile_commands.json`供cquery使用

运行起来效果大概是由Emacs来启动一个cquery进程，由c-mode的hook启动cquery以及顺便打开company补全插件的lsp后端（代码补全）。

cquery需要在源码目录下放置一个`compile_commands.json`文件，可以由cmake在生成编译配置时顺便生成：

`cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=YES CMakeLists.txt`

配置好lsp-mod后，缩进变得比较诡异，因为lsp-mode似乎是让cquery来进行缩进，然而我并没有发现cquery有关缩进的文档，所以我用Emacs自己的语法缩进，并关闭了这个功能：

`(custom-set-variables '(lsp-enable-indentation nil))`

（注意：根据源码，若要关闭缩进功能，必须在进入lsp-mode之前就关闭）

--------------------------------

啊，写得像草稿一样，日后有空再修改。
