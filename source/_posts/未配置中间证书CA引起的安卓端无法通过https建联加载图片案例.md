---
title: 未配置中间证书CA引起的安卓端无法通过https建联加载图片案例
date: 2019-01-06 13:15:04
tags: linux
---

## 问题描述

安卓同事称代码调试访问test-material.aaa.tv/xxx/xxxx.png等图片资源的时候报错，报错信息类似如下：

```
javax.net.ssl.SSLHandshakeException: java.security.cert.CertPathValidatorException: Trust anchor for certification path not found.
```

## 问题分析

查看了安卓的开放文档，出现该报错主要由一下三种情况发生：
1. [颁发服务器证书的 CA 未知](https://developer.android.google.cn/training/articles/security-ssl#UnknownCa)。
2. [服务器证书不是由 CA 签署的，而是自签署](https://developer.android.google.cn/training/articles/security-ssl#SelfSigned)。
3. [服务器配置缺少中间 CA](https://developer.android.google.cn/training/articles/security-ssl#MissingCa)。

首先排除第一点和第二点，证书是购买的赛门铁克。

然后去[ssllabs](https://www.ssllabs.com/ssltest/)网站测试`test-material.aaa.tv`域名支持的https建联加密方式
![](https://ws1.sinaimg.cn/large/9f0d15f3gy1fywswiz7etj21ia0iiabj.jpg)

起先怀疑是安卓可能使用了SSL3的加密方式进行https简练握手，后来确认安卓使用版本之后排除了该情况。

接着使用浏览器访问资源查看发现存在中间CA证书，但用域名检测网站的时候提示不含中间CA证书。于是乎又抓了一个安卓端可以显示的图片的域名来测试，在测试网站上也是属于不包含中间CA证书的情况。


两者的区别是，无法建联的域名是阿里云上的，能建联显示图片的域名是腾讯云上的。

当时很纳闷，后来查阅资料得知不同软件或者设备会有不同的行为，有些即便不存在中间CA也会帮忙代理查找。

安卓(其他苹果设备应该也是如此)自身会信任一些根证书，可能安卓去“解析”test-material.aaa.tv这个域名的时候得到的根证书，并不在信任证书里面，从而导致https建联失败。

于是发现安卓的确是存在信任一些列证书的情况：
![](https://ws1.sinaimg.cn/large/9f0d15f3gy1fywt2cigk2j20f00qoam5.jpg)

然后来获取下test-material.aaa.tv的根证书情况，自然，在浏览器端获取到的可能是浏览器帮助代理请求获得的。得在服务器端用命令去查看，命令如下：

```
openssl s_client -connect test-material.aaa.tv:443 -servername test-material.aaa.tv
```

**-connect 检测的域名，后面跟随ssl端口号**
**-servername 指定SNI(Server Name Indication)，因为可能存在多个域名对应一张证书的情况，比如买的证书是一级域名和二级域名都可以使用这种情况，那么需要指定具体的域名。**

SNI (Server Name Indication)是用来改善服务器与客户端 SSL (Secure Socket Layer)和 TLS (Transport Layer Security) 的一个扩展。主要解决一台服务器只能使用一个证书(一个域名)的缺点，随着服务器对虚拟主机的支持，一个服务器上可以为多个域名提供服务，因此SNI必须得到支持才能满足需求。

![](https://ws1.sinaimg.cn/large/9f0d15f3gy1fywt3e8uucj21yw0dk7h4.jpg)
*上图已经修复问题，修复之前只有条目0，不包含条目1。*

* 红框信息：
1. 起始证书是C=CN/L=xxxxx(后面一大串)，然后C=CN/L=xxxxx(后面一大串)这个证书又是由GeoTrust Inc./CN=GeoTrust SSL CA - G3颁发。

* 修复问题之前只有条目0,没有条目1，然后在安卓信任证书列表里面查不到关于信任GeoTrust Inc./CN=GeoTrust SSL CA - G3这个证书的条目。所以建联无法通过了。

2. GeoTrust SSL CA - G3又是由Geo Trust Inc./CN=Geo Trust Global CA颁发。

**修复问题之后可以在安卓端信任列表里面查到存在Geo Trust Global CA证书条目，所以建联成功了。**

## 问题解决方法：

中间证书CA没配置导致，上阿里云后台，查看该域名对应的证书，发现的确只有本机CA证书，没有配置中间证书CA，重新配置上后，问题解决，安卓端建联正常。

 
refer:
> https://developer.android.google.cn/training/articles/security-ssl.html#MissingCa
> http://blog.csdn.net/makenothing/article/details/53292335

 

证书检测地址:
> https://www.ssllabs.com/ssltest/analyze.html

## 安卓文档对于缺失中间证书的描述:
```
有趣的是，在大多数桌面浏览器中访问此服务器不会引发完全未知的 CA 或自签署服务器证书所引发的类似错误。这是因为大多数桌面浏览器都会将可信的中间 CA 缓存一段时间。当浏览器从某个网站访问和了解中间 CA 后，下次它就不需要将中间 CA 添加在证书链中。

有些网站会专门为提供资源的辅助网络服务器这样做。例如，他们可能让具有完整证书链的服务器提供主 HTML 页面，让不包含 CA 的服务器提供图像、CSS 或 JavaScript 等资源，以节省带宽。遗憾的是，这些服务器有时候可能会提供您正在尝试从 Android 应用调用的网络服务，这一点让人难以接受。

可以通过两种方法解决此问题：

配置服务器以便在服务器链中添加中间 CA。大多数 CA 都可以提供有关如何为所有常用网络服务器执行此操作的文档。如果您需要网站至少通过 Android 4.2 使用默认 Android 浏览器，那么这是唯一的方法。
或者，像对待其他任何未知 CA 一样对待中间 CA，并创建一个 TrustManager 以直接信任它，如前面的两部分中所述。
```
 

 

## 查看证书到期时间：

openssl s_client -connect www.icoinbay.com:443 -servername www.icoinbay.com 2>/dev/null |openssl x509 -noout -dates 
