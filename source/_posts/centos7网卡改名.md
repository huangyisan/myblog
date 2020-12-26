---
title: centos7网卡改名
date: 2018-12-27 17:22:38
tags: linux
---

客户瞎搞，两张网卡，说是看着名称不爽，自行修改了网卡名，为bond0和bond1，bond1能启动，而bond0无法启动。
我这边接手擦屁股。

先说udev服务，然后再看问题产生的原因。

## system-udevd进程

在centos6中为udevd进程：
```shell
[root@VM_31_91_centos6 ~]# ps -ef | grep udev
root       470     1  0 01:17 ?        00:00:00 /sbin/udevd -d
```

<!-- more -->

在centos7中为system-udevd进程
```shell
[root@VM_31_91_centos7 ~]# ps -ef | grep udev
root       460     1  0 10月09 ?      00:00:00 /usr/lib/systemd/systemd-udevd
```

* udev的作用是：
`man udev`
receives device uevents directly from the kernel whenever a device is added or removed from the system, or it changes its state.
当有设备从系统插入或者拔出，或者改变了状态的时候，内核会直接收到设备uevents。

* udev rules文件存在位置：
1. system rules directory: /usr/lib/udev/rules.d
2. volatile runtime directory: /run/udev/rules.d
3. local administration directory: /etc/udev/rules.d

* udev读取文件规则：
1. 读取这些目录下以.rules为后缀的文件。
2. 文件先后顺序和其所在目录无关，和文件的名称顺序有关。
3. 若不同目录存在相同的文件，则根据目录名称来排优先级顺序。/etc>/run>/usr

* udev进行网卡重命名
> https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/networking_guide/sec-understanding_the_device_renaming_procedure?tdsourcetag=s_pctim_aiomsg

**优先查询的是`/usr/lib/udev/rules.d/60-net.rules`配置文件。**如果发现包含 HWADDR 条目的 ifcfg 文件与某个接口的 MAC 地址匹配，它会将该接口重命名为 ifcfg 文件中由 DEVICE 指令给出的名称。

## 问题产生的原因

当时发现`/usr/lib/udev/rules.d/60-net.rules`文件内已经存在了bond1的配置，而bond0的配置写到了`/etc/udev/rules.d/70-persistent-net.rules`里面，由于60的优先级高于70，所以bond0网卡一直起不来。

其实centos7已经不用`70-persistent-net.rules`这个文件了，在centos6中，删除了`70-persistent-net.rules`文件，他会通过`/lib/udev/write_net_rules`文件来生成，但centos7已经不存在该文件了，centos7是使用`/lib/udev/rename_device`文件来生成`/usr/lib/udev/rules.d/60-net.rules`。

## 合理修改centos7网卡名称流程

首先修改当前网卡名称

```
/sbin/ip link set eth1 down
/sbin/ip link set eth1 name eth123
/sbin/ip link set eth123 up
```

然后在`/usr/lib/udev/rules.d/60-net.rules`中加入配置策略
ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{address}=="00:50:56:8e:3f:a7", NAME="eth123"

最后修改ifcfg-xxx里面的NAME和DEVICE字段值为eth123。

重启网卡即可。

refer:
> https://www.freedesktop.org/software/systemd/man/udev.html#
> https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/networking_guide/sec-understanding_the_device_renaming_procedure?tdsourcetag=s_pctim_aiomsg
> https://unix.stackexchange.com/questions/205010/centos-7-rename-network-interface-without-rebooting
