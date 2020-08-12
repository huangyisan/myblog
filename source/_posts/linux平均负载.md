---
title: linux平均负载
date: 2019-02-05 12:37:17
tags: [linux,cpu]
---


## linux平负载定义

1. 单位时间内，处于**运行或者准备运行(R)**，以及**不可中断睡眠进程(D)**数量的平均值(指数平滑法)。
2. 和cpu使用率没有直接关系。
3. 负载上升，可能是cpu使用率过高，也可能是磁盘io问题。



## 平均负载算法

其算法为`指数平滑法`，内核因为不可以直接做浮点运算，而选择**定点运算**的方式来计算指数平滑法。

指数平滑法公式：

1. linux 2.6.18内核 load<sub>t</sub> = load<sub>t-1</sub> * α + n * (1 – α)，[0 < α < 1]

2. linux 3.12内核 load<sub>t</sub> = load<sub>t-1</sub> * α + n * (1 – α) + z，[0 < α < 1]    *3.12内核增加了修正值z。*

load<sub>t</sub>表示当前时刻一段时间内的平滑均值。
load<sub>t-1</sub>表示上一时间段的平滑均值。
α Linux Kernel要计算的是前1min, 5min, 15min的Load 均值，α需要分别选取。Linux Kernel选取的是: e<sup>-5/(60*m)</sup>
5:表示5s，作分子。
60:表示60s。
m: 表示分钟，1, 5, 15。 60 * m作为分母。
把m带入到公式计算，分别能计算出0.920044415，0.983471454，0.994459848

参考文档:
> http://brytonlee.github.io/blog/2014/05/07/linux-kernel-load-average-calc/


## multi-core vs multi-processor

1. load关注机器有多少个processor
```
此公式包含超线程数。
[root@leanote ~]# cat /proc/cpuinfo | grep "processor" | wc -l
1
[root@leanote ~]# 
```

3. core可以理解为核心数，也就是cpu核心总数，而processor理解为逻辑cpu个数，而非真实cpu个数，这个逻辑cpu个数等于top后按1查看到的结果。

## linux查看cpu信息

总核数 = 物理CPU个数 X 每颗物理CPU的核数 
总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数

查看物理CPU个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l

查看每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo| grep "cpu cores"| uniq

查看逻辑CPU的个数
cat /proc/cpuinfo| grep "processor"| wc -l




refer
> http://brytonlee.github.io/blog/2014/05/07/linux-kernel-load-average-calc/



