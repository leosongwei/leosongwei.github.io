GnuPG
-----

tags: gpg; encrypt; public key;

对这个博客的commit开启了签名，我有一个理论：**对于未曾谋面的人，他/她用一个钥匙签名的发言次数越多，越能说明这个公钥是属于这个人的**。

网络上，一个你未曾谋面的人，你是无从分辨他在多个地方的发言是其本人发表的，亦或只是模仿者所作（甚至是社交平台的提供商所伪造）。

然而若是有多处**连贯**的言论被同一把钥匙签名，那么这些言论就有了不可抵赖的连贯性。如果有很多处言论都被这把密钥签名，且那个人在不签名的场合也常提及被签名验证的信息，那么我们就可以说这把钥匙是这个人的，**这时给这把公钥签名就是没有问题的了**。

TonyChyi评论说这个理论相当于是“*某个人见的越多，越了解这个人*”这句话的翻版。

我的公钥
--------

我的公钥在这里：`./attachment/leo_songwei_201609.asc`

新密钥的信息：
```
pub   4096R/C583B54E 2016-09-26 [有效至：2017-09-26]
密钥指纹 = 5C69 D3D0 3EB8 FB14 75FC  86E5 8003 8760 C583 B54E
uid                  Song Wei (Leo, 凉拌茶叶, 2016.09) <leo_songwei@outlook.com>
uid                  Leo Song (126邮箱) <leo_songwei@126.com>
sub   4096R/771ED4FB 2016-09-26 [有效至：2017-09-26]
```
奇怪的Git签名问题
-----------------

配置Git签名的时候会遇到错误“secret key not available”，这样配置即可：

`git config --global user.signingkey 16614B93`

（把里面的短ID换成你自己的即可）

吊销了旧的密钥对
----------------

被吊销的密钥的信息：`./attachment/leo_songwei_revoked.asc`

```gpg
pub   4096R/16614B93 2015-01-29 [已吊销：2016-09-26]
密钥指纹 = 36D0 8649 4FF1 653D 8137  BE94 C293 0408 1661 4B93
uid                  Song Wei (宋为) <leo_songwei@outlook.com>
uid                  leo_song (Song Wei) <leo_songwei@126.com>
```

吊销证书见：`./attachment/leo_songwei_revoke.asc`
