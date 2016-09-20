GnuPG
-----

我的公钥在这里：`./attachment/leo_songwei.asc`

指纹是：
`36D0 8649 4FF1 653D 8137 BE94 C293 0408 1661 4B93`

对这个博客的commit开启了签名，我有一个理论：对于未曾谋面的人，他/她用一个钥匙签名的发言次数越多，越能说明这个公钥是属于这个人的。

配置Git签名的时候会遇到错误“secret key not available”，这样配置即可：

`git config --global user.signingkey 16614B93`

（把里面的短ID换成你自己的即可）
