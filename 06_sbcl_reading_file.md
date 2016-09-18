SBCL读文件
==========

Tag: Lisp; SBCL; file; stream; io; type; very slow;

SBCL里面读写文件千万不要写`'unsigned-byte`，老老实实写`'(unsigned-byte 8)`，要不然死慢！
