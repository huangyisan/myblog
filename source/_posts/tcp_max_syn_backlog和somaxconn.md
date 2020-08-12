---
title: tcp_max_syn_backlog和net.core.somaxconn
date: 2019-02-11 13:22:38
tags: [linux,network]
---

**kernel 3.10.0-693.2.2.el7.x86_64**

## 两个队列

tcp的建联存在两种状态
1. incomplete connection queue  未建联的队列
2. completed connection queue   已建联的队列

* 未建联的队列
  * 客户端发出syn请求，并且已经达到服务端，服务端返回syn+ack,等待对端响应ack时候的队列。
  * 这些套接口处于SYN_RCVD状态。

* 已建联的队列
  * 客户端发送建联请求，并且已经和服务端完成了三次握手，但此时这个socket还未被程序使用。(如何拿出来使用，则需要调用accept()函数)
  * 这些套接口处于ESTABLISHED状态。

## listen()和accept()函数

三次握手图

![](http://ww1.sinaimg.cn/large/9f0d15f3gy1g02g8ez0asj20uz0en0te.jpg)

一段python服务端网络编程代码：

```
import socket

s = socket.socket()
host = "0.0.0.0"
port = 12345
s.bind((host, port))
BACKLOG = 5

s.listen(BACKLOG)
while True:
    c, addr = s.accept()
    print("conn addr : ", addr)
    c.send("hello word")
    c.close()
```

上述代码listen()和accept()解释如下

# listen()函数

listen()函数的主要作用就是将套接字(sockfd)变成被动的连接监听套接字(被动等待客户端的连接)。

# accept()函数

从处于 completed connection queue状态的连接队列头部取出一个已经完成的连接，如这个队列没有已经完成的连接，accept()函数就会阻塞，直到取出队列中已完成的用户连接为止。

**如果程序不调用accept()函数，那么连接socket一直滞留在completed connection queue队列里面，进而未被程序消费使用。**

比如如下代码:

```
import socket
import time

s = socket.socket()
host = "0.0.0.0"
port = 12345
s.bind((host, port))
BACKLOG = 5

s.listen(BACKLOG)
print('listening')
time.sleep(3600)
```

## somaxconn
The behavior of the backlog argument on TCP sockets changed with Linux 2.2. Now it specifies the queue length for **completely established** sockets waiting to be accepted, instead of the number of incomplete connection requests. 

If the backlog argument is greater than the value in /proc/sys/net/core/somaxconn, then it is silently truncated to that value; the default value in this file is 128. In kernels before 2.4.25, this limit was a hard coded value, SOMAXCONN, with the value 128.

1. somaxconn用来指定系统定义的建联队列的长度(ESTAB状态的连接数量)。
2. 若程序中定义的listen函数的backlog大于系统定义的，则以系统定义为准。

### 代码实践 somaxconn

python的一个不含accept()的服务端代码，这样可以让socket滞留在completed connection queue队列里面。

```
import socket
import time

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
host = "0.0.0.0"
port = 12345
s.bind((host, port))
BACKLOG = 2

s.listen(BACKLOG)
print('listening')
time.sleep(3600)
```

查看下系统somaxconn的值：
```
[root@leanote ~]# sysctl -a | grep somaxconn
net.core.somaxconn = 128
```

启动进程，**先不使用客户端进行连接**，使用ss查看进程pid。

```
[root@leanote ~]# ss -anpl | egrep "10187|Recv-Q"
Netid  State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
tcp    LISTEN     0      5         *:12345                 *:*                   users:(("python3",pid=10187,fd=3))
```

这里涉及到Recv-Q和Send-Q两个字段，这两个字段的含义和前面state字段为何种状态密不可分，解释如下

* Recv-Q
  * Established: The count of bytes not copied by the user program connected to this socket.(套接字缓冲还没有被应用程序取走的字节数)
  * Listening: Since Kernel 2.6.18 this column contains the current syn backlog. (当前syn backlog为backlog+1)

* Send-Q
  * Established: The count of bytes **not acknowledged** by the remote host.(没有被远端确认的字节数)
  * Listening: Since Kernel 2.6.18 this column contains the maximum size of the syn backlog.
 

  
**Send-Q 对应的值是5，这个值也就是代码中listen()中BACKLOG的值。**

此时如果调整BACKLOG至256，重新启动进程，然后用ss查看信息：

```
import socket
import time

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
host = "0.0.0.0"
port = 12345
s.bind((host, port))
BACKLOG = 256

s.listen(BACKLOG)
print('listening')
time.sleep(3600)
```

```
[root@leanote ~]# ss -anp |egrep "12345|Recv-Q"
Netid  State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
tcp    LISTEN     0      128       *:12345                 *:*                   users:(("python3",pid=19593,fd=3))
```

Send-Q被系统somaxcon限制为128，调整系统somaxcon的值后，重启进程，然后ss继续观察

```
[root@leanote ~]# sysctl net.core.somaxconn=65522
net.core.somaxconn = 65522
```

```
[root@leanote ~]# ss -anp |egrep "12345|Recv-Q"
Netid  State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
tcp    LISTEN     0      256       *:12345                 *:*                   users:(("python3",pid=19839,fd=3))
```

变成了程序代码里定义的BACKLOG值了。



**让客户端进行建联**

客户端代码：

```
import socket
import time
host = '122.152.220.151'
port = 12345
sockets=[]
while True:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    sockets.append(s)
    time.sleep(10)
```

**代码中BACKLOG修改为2**

使用ss观察服务端

```
[root@leanote ~]# ss -anp |egrep "12345|Recv-Q"
Netid  State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
tcp    LISTEN     3      2         *:12345                 *:*                   users:(("python3",pid=20361,fd=3))
tcp    SYN-RECV   0      0      10.105.31.91:12345              118.24.105.81:35986              
tcp    SYN-RECV   0      0      10.105.31.91:12345              118.24.105.81:36012              
tcp    SYN-RECV   0      0      10.105.31.91:12345              89.248.167.131:56380              
tcp    SYN-RECV   0      0      10.105.31.91:12345              118.24.105.81:35994              
tcp    SYN-RECV   0      0      10.105.31.91:12345              118.24.105.81:36002              
tcp    ESTAB      0      0      10.105.31.91:12345              118.24.105.81:35972              
tcp    ESTAB      0      0      10.105.31.91:12345              118.24.105.81:35952              
tcp    ESTAB      0      0      10.105.31.91:12345              118.24.105.81:35960                          
```

**建联3个后(ESTAB),其他请求一直处于SYN-RECV状态。**

Recv-Q为3，表示当前syn backlog为3 ,backlog+1的结果(2+1)。

当BACKLOG满的时候，抓包情况：
```
[root@leanote ~]# tcpdump -i any port 12345 -nnn > 111
[root@leanote ~]# cat 111 | grep  37182
16:11:58.519076 IP 118.24.105.81.37182 > 10.105.31.91.12345: Flags [S], seq 1450185841, win 29200, options [mss 1424,sackOK,TS val 3561765739 ecr 0,nop,wscale 7], length 0
16:11:58.519145 IP 10.105.31.91.12345 > 118.24.105.81.37182: Flags [S.], seq 1044766216, ack 1450185842, win 28960, options [mss 1460,sackOK,TS val 3121876725 ecr 3561765739,nop,wscale 7], length 0
16:11:58.578420 IP 118.24.105.81.37182 > 10.105.31.91.12345: Flags [.], ack 1, win 229, options [nop,nop,TS val 3561765798 ecr 3121876725], length 0
16:11:59.853632 IP 10.105.31.91.12345 > 118.24.105.81.37182: Flags [S.], seq 1044766216, ack 1450185842, win 28960, options [mss 1460,sackOK,TS val 3121878060 ecr 3561765798,nop,wscale 7], length 0
16:11:59.912872 IP 118.24.105.81.37182 > 10.105.31.91.12345: Flags [.], ack 1, win 229, options [nop,nop,TS val 3561767133 ecr 3121876725], length 0
16:12:02.053621 IP 10.105.31.91.12345 > 118.24.105.81.37182: Flags [S.], seq 1044766216, ack 1450185842, win 28960, options [mss 1460,sackOK,TS val 3121880260 ecr 3561767133,nop,wscale 7], length 0
16:12:02.112871 IP 118.24.105.81.37182 > 10.105.31.91.12345: Flags [.], ack 1, win 229, options [nop,nop,TS val 3561769333 ecr 3121876725], length 0
16:12:06.253625 IP 10.105.31.91.12345 > 118.24.105.81.37182: Flags [S.], seq 1044766216, ack 1450185842, win 28960, options [mss 1460,sackOK,TS val 3121884460 ecr 3561769333,nop,wscale 7], length 0
16:12:06.312908 IP 118.24.105.81.37182 > 10.105.31.91.12345: Flags [.], ack 1, win 229, options [nop,nop,TS val 3561773533 ecr 3121876725], length 0
16:12:14.253636 IP 10.105.31.91.12345 > 118.24.105.81.37182: Flags [S.], seq 1044766216, ack 1450185842, win 28960, options [mss 1460,sackOK,TS val 3121892460 ecr 3561773533,nop,wscale 7], length 0
16:12:14.312821 IP 118.24.105.81.37182 > 10.105.31.91.12345: Flags [.], ack 1, win 229, options [nop,nop,TS val 3561781533 ecr 3121876725], length 0
16:12:30.253631 IP 10.105.31.91.12345 > 118.24.105.81.37182: Flags [S.], seq 1044766216, ack 1450185842, win 28960, options [mss 1460,sackOK,TS val 3121908460 ecr 3561781533,nop,wscale 7], length 0
16:12:30.312821 IP 118.24.105.81.37182 > 10.105.31.91.12345: Flags [.], ack 1, win 229, options [nop,nop,TS val 3561797533 ecr 3121876725], length 0
```

对客户端一直发送syn+ack包。([S.]  S表示syn，.表示ack)
6次后，不再继续发送

虽然服务端ESTAB状态只有3个，但是对客户端而言，存在多个

```
[root@VM_0_15_centos ~]# netstat -ant | grep 12345
tcp        0      0 172.27.0.15:37326       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37410       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37312       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37242       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37232       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37360       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37266       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37442       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37458       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37468       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37214       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37392       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37282       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37292       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37182       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37174       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37222       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37370       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37400       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37430       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37206       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37418       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37342       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37352       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37252       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37384       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37334       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37274       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37450       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37300       122.152.220.151:12345   ESTABLISHED
tcp        0      0 172.27.0.15:37192       122.152.220.151:12345   ESTABLISHED
```

对于客户端而言，服务端发送了syn+ack已经算是三次握手成功了。

## tcp_max_syn_backlog

The maximum number of queued connection	requests which have still **not received** an acknowledgement from the connecting client. If this number is exceeded, the kernel will begin drop-ping requests.The maximum length of the queue for incomplete sockets can be set using /proc/sys/net/ipv4/tcp_max_syn_backlog. When syncookies are enabled there is no logical maximum length and this setting is ignored

1. tcp_max_syn_backlog用来定义未建联的SYN-RECV状态队列长度。
2. 当启用syncookies功能的时候，tcp_max_syn_backlog的功能将被忽视。

###代码实践 tcp_max_syn_backlog


查看下系统tcp_max_syn_backlog的值：
[root@leanote ~]# sysctl -a | grep tcp_max_syn_backlog
net.ipv4.tcp_max_syn_backlog = 128

服务端ss查看
```
[root@leanote ~]# netstat -ant | grep 12345
tcp        3      0 0.0.0.0:12345           0.0.0.0:*               LISTEN     
tcp        0      0 10.105.31.91:12345      118.24.105.81:37926     SYN_RECV   
tcp        0      0 10.105.31.91:12345      118.24.105.81:37894     SYN_RECV   
tcp        0      0 10.105.31.91:12345      118.24.105.81:37944     SYN_RECV   
tcp        0      0 10.105.31.91:12345      118.24.105.81:37936     SYN_RECV   
tcp        0      0 10.105.31.91:12345      118.24.105.81:37908     SYN_RECV   
tcp        0      0 10.105.31.91:12345      118.24.105.81:37918     SYN_RECV   
tcp        0      0 10.105.31.91:12345      118.24.105.81:37874     ESTABLISHED
tcp        0      0 10.105.31.91:12345      118.24.105.81:37864     ESTABLISHED
tcp        0      0 10.105.31.91:12345      118.24.105.81:37882     ESTABLISHED
```

输出发现SYN_RECV状态状态很多，**虽然连接处于SYN_RECV**，一段时间后，自动删除，但是通过调整tcp_max_syn_backlog的值可以调整同一时间内SYN_RECV的数量。

调整成为2个：
```
[root@leanote ~]# sysctl net.ipv4.tcp_max_syn_backlog=2
net.ipv4.tcp_max_syn_backlog = 2
```

因为当syncookies功能开启的时候，tcp_max_syn_backlog不会发挥作用，所以syncookies也得暂停：
```
[root@leanote ~]# sysctl net.ipv4.tcp_syncookies=0
net.ipv4.tcp_syncookies = 0
```

客户端服务端重启，然后ss查看状态：
```
[root@leanote ~]# ss -ant | grep 12345
LISTEN     3      2            *:12345                    *:*                  
SYN-RECV   0      0      10.105.31.91:12345              118.24.105.81:38456              
SYN-RECV   0      0      10.105.31.91:12345              118.24.105.81:38470              
SYN-RECV   0      0      10.105.31.91:12345              118.24.105.81:38398              
ESTAB      0      0      10.105.31.91:12345              118.24.105.81:38280              
ESTAB      0      0      10.105.31.91:12345              118.24.105.81:38264              
ESTAB      0      0      10.105.31.91:12345              118.24.105.81:38272    
```

这个syn_backlog设定的是2，但观察SYN-RECV最多出现3个。可能也是syn_backlog+1。待考证。

```
[root@leanote ~]# netstat -s | grep drop
    20 dropped because of missing route
    19 ICMP packets dropped because they were out-of-window
    92307 SYNs to LISTEN sockets dropped
    
[root@leanote ~]# dmesg  | tail -n 10
[3124021.575444] TCP: drop open request from 118.24.105.81/38910
[3124025.583391] TCP: drop open request from 118.24.105.81/38910
[3124033.599301] TCP: drop open request from 118.24.105.81/38910
[3124049.647044] TCP: drop open request from 118.24.105.81/38910
[3124111.900356] TCP: drop open request from 118.24.105.81/38996
[3124112.902233] TCP: drop open request from 118.24.105.81/38996
[3124114.908171] TCP: drop open request from 118.24.105.81/38996
[3124118.916112] TCP: drop open request from 118.24.105.81/38996
[3124126.924020] TCP: drop open request from 118.24.105.81/38996
[3124142.955770] TCP: drop open request from 118.24.105.81/38996
```

服务器开始丢弃syn包，以及丢弃从客户端发送来的新连接。

## 总结

* tcp_max_syn_backlog用来定义未建联的SYN-RECV状态队列长度。但当启用syncookies功能的时候失效。
* somaxconn会限制listen()函数中BACKLOG的值。

**somaxconn在高并发下需要调整，默认128绝逼不够用。**



refer
> https://www.jianshu.com/p/30b861cac826
> https://www.jianshu.com/p/7fde92785056
> https://linux.die.net/man/2/listen
> http://www.agr.unideb.hu/~agocs/informatics/11_e_unix/unixhelp/unixhelp.ed.ac.uk/CGI/man-cgiaa65.html?tcp+7
> http://zake7749.github.io/2015/03/17/SocketProgramming/
> http://man7.org/linux/man-pages/man2/accept.2.html
> https://blog.csdn.net/tennysonsky/article/details/45621341


