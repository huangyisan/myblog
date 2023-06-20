---
title: prometheus曲线救国添加hostname
date: 2019-03-07 17:45:38
tags: prometheus
---

## 问题场景
1. prometheus scrape_configs采用的是file_sd_configs，通过这种方式获取到的node_exporter的metric，元数据不存在hostname信息。
2. 只看ip，无法知道该机器的用户。
3. grafana展现的时候，能根据hostname进行选择，展现机器数据。

<!-- more -->

## 方法
1. node_exporter中启用textfile采集的方式。
2. 在textfile目录下，写入hostname。
3. 通过表达式获取hostname。

## 待解决的问题
1. 如何做到hostname的更变。
2. 表达式hostname只和写入的metric有关，如何关联到不存在hostname的metric中。

## 解决方法
1. 针对hostname的更变，让node_exporter启动的时候就进行自动读取当前hostname，并且写入。如果是配合supervisord或者systemd，则很好实现，比如用systemd守护的方式的时候，可以启用`ExecStartPre`方法，启动之前执行命令。
```shell
ExecStartPre=/opt/scripts/gethostname.sh

# cat /opt/scripts/gethostname.sh
#!/bin/bash
echo -e "# HELP hardware_status check hardware status.\n# TYPE machine_role gauge\nmachine_role{role=\"`/usr/bin/hostname`\"} 0" > /app/local/node_exporter/collect/hostname.prom
echo 1 > /dev/null
```

2. 让不存在metric的hostname关联，则需要一个共同的**连接点**，类似sql中的两表查询。
先看hostname的metric
```
# HELP machine_role Metric read from /app/local/node_exporter/collect/hostname.prom
# TYPE machine_role gauge
machine_role{role="postfix01"} 0
```

其label是role，value是postfix01，也就是hostname

prometheus中执行执行`machine_role`,可以得到element为：
```
machine_role{instance="10.1.11.1:9100",ip="10.1.11.1",job="L3",role="ShangHai-SJ-L3-LC-Flume-01",service="L3"}
```
这边有role和instance这个两个label，其中role为hostname的label，而instance则作为连接点的label。

在grafana中的变量配置中就可以根据machine_role，先获取role，作为$hostname的值
```
label_values(machine_role{service="$job"},role)
```

然后再根据$hostname，来获取instance,作为$node的值
```
label_values(machine_role{role="$hostname"},instance)
```

此时对grafana的表达式就可以使用$node值了，比如如下表达式，虽然node_cpu_seconds_total方法里面是不存在hostname的，但因为曲线救国的方式，通过$hostname取得$node，然后传入node_cpu_seconds_total方法中，则可以出现数据了。
```
count(count(node_cpu_seconds_total{instance=~"$node", mode='system'}) by (cpu))
```

## 效果截图
* 先获取hostname。
![](http://ww1.sinaimg.cn/large/9f0d15f3gy1g0udfxseayj20k20hzq3x.jpg)

* 再根据hostname获取node。隐藏了label，这个无所谓是否隐藏，我只是想知道具体ip是什么。
![](http://ww1.sinaimg.cn/large/9f0d15f3gy1g0udggcklej20j50eymxx.jpg)

* 下拉通过hostname就可以选择机器了。
![](http://ww1.sinaimg.cn/large/9f0d15f3gy1g0udhov6xnj20t00jn401.jpg)

## 其他说明
* 如果是通过dns方式发现，则是可以把hostname变成元label的。
* 通过consul发现，则可以在consul客户端上报hostname，也可以把hostname变成元label。

## 待解决问题第二点解决方法
**promSQL可以使用on ignore group_left group_right配合来把hostname拼凑进去。**

machine_role查询得到的结果:

```
machine_role{instance="10.1.11.1:9100",ip="10.1.11.1",job="L3",role="zabbix",service="L3"}  0
```

up查询得到的结果:

```
up{instance="10.1.11.1:9100",ip="10.1.11.1",job="L3",service="L3"}  1
```

machine_role里面的role标签包含了主机名，但up没有，此时通过将两个方法结合在一起。
使用on方法，*可以理解为mysql的两表查询join* 两者的有共同的instance,job,service,ip标签

不一定要全部都选择，但选择的多则相互匹配更加精确，`on(instance,job,service,ip)`

使用group_left或者group_right标记"多"的标签,这边多出来的标签是role，所以为`group_left(role)`

表达式架构为:

```
<vector expr> <bin-op> on(<label list>) group_left(<label list>) <vector expr>
```

<bin-op>指加减乘除余幂

所以将up和machine_role拼凑和可以写为

```
up + on(instance, job,ip,service) group_left(role) machine_role
{instance="10.1.11.1:9100",ip="10.1.11.1",job="L3",role="zabbix",service="L3"}  1
```

如果用group_right，则把up和machine_role反一下即可

```
machine_role + on(instance, job,ip,service) group_right(role) up 
```

此时得到的结果包含了role，如果作为告警，由于up为1表示正常，machine_role设置的是0，两者相加，若为0，则表示机器down。
告警表达式可以写成:

```
up + on(instance, job,ip,service) group_left(role) machine_role == 0
```

此时如果告警，则会包含role这个标签，就可以传递给alertmanager，获取到role了。

refer
> https://www.robustperception.io/how-to-have-labels-for-machine-roles
> https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/promql/prometheus-promql-operators-v2