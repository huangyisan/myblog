---
title: 'bash fork: retry: Resource temporarily unavailable'
date: 2019-01-02 23:16:17
tags: linux
---


## 修改ulimit无法解决fork不出子进程的问题
现场没有保留，大抵经过如下：
朋友的一台系统为Ubuntu的机器，上面启动了一个进程，该进程会fork出子进程，但是当root用户所有的进程数到一万多后就无法继续fork了，输入命令开始报错`bash fork: retry: Resource temporarily unavailable`

<!-- more -->

排查经过：
1. 起先我以为是ulimit的配置没修改，或者不够大，但使用ulimit -u看了下，65535，足够大了。
2. 感觉虽然ulimit调整了，但是执行中的进程limit并没有到达65535，于是乎，去/proc/pid/limit查看了，发现max process也是65535。
3. 那么不成是内存，cpu之类的(其实想想也不太可能，内存小也不会报fork错误)，看了发现完全够用。

这下懵圈了

`bash fork: retry: Resource temporarily unavailable` 这个报错绝逼是某个参数的配置配小了。

由于是Ubuntu的系统，所以和平常用的centos还是有区别的。选择谷歌了，查来查去，一堆人都说是修改ulimit参数。

最后是找到了这篇文章：
> https://askubuntu.com/questions/845380/bash-fork-retry-resource-temporarily-unavailable

里面让修改的地方是一个名为pid.max的文件，和我机器路径稍微有点出入，我的路径是在`/sys/fs/cgroup/pids/user.slice/user-0.slice/pid.max` 这个数值只有10813，所以`ps -eLf | wc -l`到一万七八就上不去了。

* 这个文件的数量改动后立马生效，不需要重启
* 重启机器后，这个值又会还原成10813，看来Ubuntu系统默认pid.max的值为10813(当时我没注意Ubuntu具体是哪个版本。。。。)，这个值如何产生的目前还不太清楚。


## centos7
在centos7上
* 获取当前进程数：`cat /sys/fs/cgroup/pids/pids.current`   类似使用`ps -ef | wc -l`
* 获取当前**线程数和进程数**总和：`wc -l /sys/fs/cgroup/pids/tasks`  类似使用`ps -eLf | wc -l`

centos7上也是可以实现pid.max：
只需要在/sys/fs/cgroup/pids/下创建以为目录，则该目录中就会自动创建pid.max：
```
[root@leanote test]# pwd
/sys/fs/cgroup/pids/test
[root@leanote test]# ls
cgroup.clone_children  cgroup.event_control  cgroup.procs  notify_on_release  pids.current  pids.max  tasks
```

对当前shell交互进程限制

```
[root@leanote test]# ls
cgroup.clone_children  cgroup.event_control  cgroup.procs  notify_on_release  pids.current  pids.max  tasks
[root@leanote test]# cat cgroup.procs 
[root@leanote test]# echo $$
14514
[root@leanote test]# echo 14514 > cgroup.procs 
[root@leanote test]# echo 1 > pids.max 
-bash: fork: retry: No child processes
-bash: fork: Resource temporarily unavailable
-bash: fork: retry: No child processes
-bash: fork: retry: No child processes

```


* 给pid.max输入1后，直接就出`-bash: fork: retry: No child processes`报错了。
* pid.max只会对cgroup.procs中存在的进程进行pid.max限制。
* 当进程消失后,cgroup.procs中的进程号也会自动消失。



在上一级不存在pid.max是因为对整个系统没必要做限制。
Ubuntu系统上`/sys/fs/cgroup/pids/user.slice/user-0.slice/pid.max`这个其实是对用户编号为0的用户进行了pid.max的限制。



refer:

知乎上看到有个小伙伴也遇到这个问题了
> https://zhuanlan.zhihu.com/p/29192624

fork的文档
> http://man7.org/linux/man-pages/man2/fork.2.html

cgroup介绍
> https://segmentfault.com/a/1190000007241437
> https://mccxj.github.io/blog/20171230_os-thread-limit.html

cgroup 进程数限制
> https://segmentfault.com/a/1190000007468509

