flash-attn安装困难
=====

tags: python; pip; flash-attn; llm; transformers; proxy;

1. flash-attn很难构建，要真的构建出来恐怕得开动NVIDIA家的一票编译器折腾几个小时去了
2. 它的wheel藏在github上，pypa里没有，pip install 的时候whl文件的url是`bdist_wheel`猜出来的，在Github上，像是这样：

```
  Building wheel for flash-attn (setup.py) ... error
  error: subprocess-exited-with-error
  
  × python setup.py bdist_wheel did not run successfully.
  │ exit code: 1
  ╰─> [9 lines of output]
      致命错误：不是 git 仓库（或者任何父目录）：.git
      
      
      torch.__version__  = 2.2.0+cu121
      
      
      running bdist_wheel
      Guessing wheel URL:  https://github.com/Dao-AILab/flash-attention/releases/download/v2.5.3/flash_attn-2.5.3+cu122torch2.2cxx11abiFALSE-cp311-cp311-linux_x86_64.whl
      error: <urlopen error [Errno -2] Name or service not known>
      [end of output]
```

但是呢pip install的时候那个`bdist_wheel`的地方很难设置代理，就头疼了。所以我们采取野蛮的办法：手工下载这个文件，给它塞进pip缓存中。好，问题来了，`/home/user/.cache/pip/wheels`文件夹里面是这个鬼样子：

```
...
./f1
./f1/06
./f1/06/79
./f1/06/79/ccf5662ac648c238e3e2844d71ff681bdcdbe87173aa89587c
./f1/06/79/ccf5662ac648c238e3e2844d71ff681bdcdbe87173aa89587c/deepspeed-0.12.6-py3-none-any.whl
./f1/06/79/ccf5662ac648c238e3e2844d71ff681bdcdbe87173aa89587c/origin.json
./80
./80/32
./80/32/8d
./80/32/8d/21cf0fa6ee4e083f6530e5b83dfdfa9489a3890d320803f4c7
./80/32/8d/21cf0fa6ee4e083f6530e5b83dfdfa9489a3890d320803f4c7/tornado-6.1-cp310-cp310-linux_x86_64.whl
...
```

那么怎样得出正确的位置呢？我就只好手撕pip。直接编辑文件`.venv/lib/python3.11/site-packages/pip/_internal/cache.py`（我假定你像我一样用  香草venv+pip）：

1. 找到`class SimpleWheelCache`
2. 在其`get_path_for_link`方法的最后一行，把那个返回的路径打印出来
3. 再来一次`pip install flash-attn`，看它下载失败报错`Building wheel for flash-attn (setup.py) ... error`
4. 此时在报错信息的上方应该能找到你打出的路径，我的log像是这样：

```
Requirement already satisfied: mpmath>=0.19 in ./.venv/lib/python3.11/site-packages (from sympy->torch->flash-attn) (1.3.0)
Building wheels for collected packages: flash-attn
cache path: /home/user/.cache/pip/wheels/0b/b5/fb/4eb31ffcf262c7b78dd3ae076329e02560008d5bb11c6c6f6d
  Building wheel for flash-attn (setup.py) ... error
  error: subprocess-exited-with-error
```

然后把这个`flash_attn-2.5.3+cu122torch2.2cxx11abiFALSE-cp311-cp311-linux_x86_64.whl`直接复制进这个`/home/user/.cache/pip/wheels/0b/b5/fb/4eb31ffcf262c7b78dd3ae076329e02560008d5bb11c6c6f6d`，路径连起来像这样：

* `/home/user/.cache/pip/wheels/0b/b5/fb/4eb31ffcf262c7b78dd3ae076329e02560008d5bb11c6c6f6d/flash_attn-2.5.3+cu122torch2.2cxx11abiFALSE-cp311-cp311-linux_x86_64.whl`

然后再安装`pip install flash-attn`就好了。
