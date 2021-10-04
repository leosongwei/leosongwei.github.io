笔记：构建clasp
================

tags: clasp; lisp; llvm;

参考：

* [build with llvm13 972b6a3a3471c2a742c5c5d8ec004ff640d544c4](https://github.com/clasp-developers/clasp/wiki/build-with-llvm13-972b6a3a3471c2a742c5c5d8ec004ff640d544c4)

我的配置：

* 用Ninja
  - 限制链接并行，防止爆内存
* 配置了binutils的头文件目录（Linux中不作特殊处理）

```bash
#!/bin/bash
mkdir build-llvm
cd build-llvm
cmake -G Ninja \
	-DLLVM_PARALLEL_LINK_JOBS=1 \
	-DLLVM_BINUTILS_INCDIR=/usr/include \
        -DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF \
        -DLINK_POLLY_INTO_TOOLS=ON \
        -DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON \
        -DLLVM_BUILD_LLVM_DYLIB=ON \
        -DLLVM_ENABLE_ASSERTIONS=OFF \
        -DLLVM_ENABLE_EH=ON \
        -DLLVM_ENABLE_FFI=ON \
        -DLLVM_ENABLE_LIBCXX=ON \
        -DLLVM_ENABLE_RTTI=ON \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_INSTALL_UTILS=ON \
        -DLLVM_OPTIMIZED_TABLEGEN=ON \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        -DLLVM_ENABLE_PROJECTS=clang\;libcxxabi\;libcxx\;lldb\; \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_POLLY=ON \
        -DCMAKE_INSTALL_PREFIX=/opt/clasp \
        -DLLVM_CREATE_XCODE_TOOLCHAIN=ON \
	../llvm-project/llvm
```
