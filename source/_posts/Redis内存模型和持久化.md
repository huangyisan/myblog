---
title: Redis内存模型和持久化(搬运)
date: 2019-07-30 14:24:07
tags: linux
categories: application
---

# Redis内存模型

## Redis内存统计

使用`info memory`进行统计

```
127.0.0.1:6379> info memory
# Memory
used_memory:853392
used_memory_human:833.39K
used_memory_rss:3375104
used_memory_rss_human:3.22M
used_memory_peak:853392
used_memory_peak_human:833.39K
used_memory_peak_perc:100.01%
used_memory_overhead:841150
used_memory_startup:791384
used_memory_dataset:12242
used_memory_dataset_perc:19.74%
allocator_allocated:1396056
allocator_active:1724416
allocator_resident:8605696
total_system_memory:1929056256
total_system_memory_human:1.80G
used_memory_lua:37888
used_memory_lua_human:37.00K
used_memory_scripts:0
used_memory_scripts_human:0B
number_of_cached_scripts:0
maxmemory:0
maxmemory_human:0B
maxmemory_policy:noeviction
allocator_frag_ratio:1.24
allocator_frag_bytes:328360
allocator_rss_ratio:4.99
allocator_rss_bytes:6881280
rss_overhead_ratio:0.39
rss_overhead_bytes:-5230592
mem_fragmentation_ratio:4.15
mem_fragmentation_bytes:2562728
mem_not_counted_for_evict:0
mem_replication_backlog:0
mem_clients_slaves:0
mem_clients_normal:49694
mem_aof_buffer:0
mem_allocator:jemalloc-5.1.0
active_defrag_running:0
lazyfree_pending_objects:0
```

几个关键的内存属性字段
1. used_memory
  * Redis分配器分配的内存总量（单位是字节），包括使用的虚拟内存（即swap）。

2. used_memory_rss
  * Redis进程占据操作系统的内存（单位是字节），与top及ps命令看到的值是一致的；除了分配器分配的内存之外，used_memory_rss还包括进程运行本身需要的内存、内存碎片等，但是**不包括虚拟内存**。

3. mem_fragmentation_ratio
  * used_memory_rss / used_memory的比值，该值越大，内存碎片越多，如果该值小于1，则表明使用了虚拟内存swap，需要对redis进行扩容，优化等操作。
  * 一般来说，mem_fragmentation_ratio在1.03左右是比较健康的状态（对于jemalloc来说）

4. mem_allocator
  * Redis使用的内存分配器，在编译时指定；可以是 libc 、jemalloc或者tcmalloc，默认是jemalloc。

## Redis内存划分

**redis除了内部数据会占用内存之外，也存在其他占用内存的地方。**

Redis的内存占用主要可以划分为以下几个部分

1. 数据(字符串、哈希、列表、集合、有序集合)
  * 数据为最主要占用内存部分，这部分内存占用**会统计在used_memory中**。

2. 进程本身运行需要的内存
  * redis进程本身运行需要内存，入代码，常量池等。因为这部分不是有jemalloc分配，因此**不会统计在used_memory中**。
  * 子进程，比如AOF，RDB也会占用内存，但**也不会统计在used_memory中**

3. 缓冲内存
  * 缓冲内存包括客户端缓冲区、复制积压缓冲区、AOF缓冲区等。这部分内存由jemalloc分配，因此**会统计在used_memory中**。

4. 内存碎片
  * 内存碎片是Redis在分配、回收物理内存过程中产生的。**不会统计在used_memory中**。

## Redis数据存储的细节

直接查看refer内容


# Redis持久化

## Redis高可用技术

1. 持久化
  * 持久化是最简单的高可用方法(有时甚至不被归为高可用的手段)，主要作用是数据备份，即将数据存储在硬盘，保证数据不会因进程退出而丢失。

2. 复制
  * 复制是高可用Redis的基础，哨兵和集群都是在复制基础上实现高可用的。复制主要实现了数据的多机备份，以及对于读操作的负载均衡和简单的故障恢复。
  * 缺陷：故障恢复无法自动化；写操作无法负载均衡；存储能力受到单机的限制。

3. 哨兵
  * 在复制的基础上，哨兵实现了自动化的故障恢复。
  * 缺陷：写操作无法负载均衡；存储能力受到单机的限制。

4. 集群
  * 通过集群，Redis解决了写操作无法负载均衡，以及存储能力受到单机限制的问题，实现了较为完善的高可用方案。

## Redis持久化类型

1. RDB
  * 将数据保存到硬盘

2. AOF
  * 将每次执行的写命令保存到硬盘

**由于AOF持久化的实时性更好，即当进程意外退出时丢失的数据更少，因此AOF是目前主流的持久化方式，不过RDB持久化仍然有其用武之地。**

## RDB持久化

**RDB可以通过手动触发，或者自动触发**

1. 手动触发
  * 在命令行界面执行`save`命令，或者`bgsave`命令。
  * save命令会阻塞Redis服务器进程，直到RDB文件创建完毕为止，在Redis服务器阻塞期间，服务器不能处理任何命令请求。
  * bgsave命令会创建一个子进程，由子进程来负责创建RDB文件，父进程(即Redis主进程)则继续处理请求。
  * bgsave命令执行过程中，只有fork子进程时会阻塞服务器，而对于save命令，整个过程都会阻塞服务器，因此save已基本被废弃，线上环境要杜绝save的使用

2. 自动触发
  * 在配置文件中配置`save m n`，表示在m秒内发生n次变化时会触发bgsave。例如 save 900 1 表示在900秒内，如果redis数据发生了至少1次变化，则执行bgsave。多条save m n命令只要满足其中一条，就会触发。
  * 在主从复制场景下，如果从节点执行全量复制操作，则主节点会执行bgsave命令，并将rdb文件发送给从节点。
  * 执行shutdown命令时，自动执行rdb持久化。

### save m n的实现原理
1. Redis的save m n，是通过serverCron函数、dirty计数器、和lastsave时间戳来实现的。

2. serverCron是Redis服务器的周期性操作函数，默认每隔100ms执行一次；该函数对服务器的状态进行维护，其中一项工作就是检查 save m n 配置的条件是否满足，如果满足就执行bgsave。

3. dirty计数器是Redis服务器维持的一个状态，记录了上一次执行bgsave/save命令后，服务器状态进行了多少次修改(包括增删改)；**而当save/bgsave执行完成后，会将dirty重新置为0**。例如，如果Redis执行了set mykey helloworld，则dirty值会+1；如果执行了sadd myset v1 v2 v3，则dirty值会+3；注意**dirty记录的是服务器进行了多少次修改，而不是客户端执行了多少修改数据的命令**。

4. lastsave时间戳也是Redis服务器维持的一个状态，记录的是上一次成功执行save/bgsave的时间。

**save m n的原理如下**

每隔100ms，执行serverCron函数；在serverCron函数中，遍历save m n配置的保存条件，只要有一个条件满足，就进行bgsave。对于每一个save m n条件，只有下面两条同时满足时才算满足

* 当前时间-lastsave > m
* dirty >= n

### bgsave执行流程

bgsave执行流程图

![](https://ws1.sinaimg.cn/large/9f0d15f3ly1g5hsqct4vtj20fe09s0tq.jpg)

五个步骤

1. Redis父进程首先判断：当前是否在执行save，或bgsave/bgrewriteaof（直接调用bgrewriteaof命令，该命令的执行与bgsave有些类似，都是fork子进程进行具体的工作，且都只有在fork时阻塞）的子进程，如果在执行则bgsave命令直接返回。bgsave/bgrewriteaof 的子进程不能同时执行，主要是基于性能方面的考虑：两个并发的子进程同时执行大量的磁盘写操作，可能引起严重的性能问题。

2. 父进程执行fork操作创建子进程，**这个过程中父进程是阻塞的，Redis不能执行来自客户端的任何命令。**

3. 父进程fork后，bgsave命令返回"Background saving started"信息并不再阻塞父进程，并可以响应其他命令。

4. 子进程创建RDB文件，根据父进程内存快照生成临时快照文件，完成后对原有文件进行原子替换。

5. 子进程发送信号给父进程表示完成，父进程更新统计信息。

### bgsave加载

1. RDB文件的载入工作是在服务器启动时自动执行的。
2. 由于AOF的优先级更高，因此当AOF开启时，Redis会优先载入AOF文件来恢复数据。
3. 只有当AOF关闭时，才会在Redis服务器启动时检测RDB文件，并自动载入。
4. 服务器载入RDB文件期间处于阻塞状态，直到载入完成为止。
5. Redis载入RDB文件时，会对RDB文件进行校验，如果文件损坏，则日志中会打印错误，Redis启动失败。

### RDB常用配置总结

1. save m n bgsave自动触发的条件；如果没有save m n配置，相当于自动的RDB持久化关闭，不过此时仍可以通过其他方式触发
2. stop-writes-on-bgsave-error yes 当bgsave出现错误时，Redis是否停止执行写命令；设置为yes，则当硬盘出现问题时，可以及时发现，避免数据的大量丢失；设置为no，则Redis无视bgsave的错误继续执行写命令，当对Redis服务器的系统(尤其是硬盘)使用了监控时，该选项考虑设置为no
3. rdbcompression yes 是否开启RDB文件压缩
4. rdbchecksum yes 是否开启RDB文件的校验，在写入文件和读取文件时都起作用；关闭checksum在写入文件和启动文件时大约能带来10%的性能提升，但是数据损坏时无法发现
5. dbfilename dump.rdb RDB文件名
6. dir ./ RDB文件和AOF文件所在目录

## AOF持久化

**AOF持久化是将Redis执行的每次写命令记录到单独的日志文件中，当Redis重启时再次执行AOF文件中的命令来恢复数据。**

**与RDB相比，AOF的实时性更好，因此已成为主流的持久化方案。**

### 开启AOF

配置文件中`appendonly yes`

### 执行流程

1. 命令追加(append)：将Redis的写命令追加到缓冲区aof_buf。
  * **Redis先将写命令追加到缓冲区，而不是直接写入文件**，主要是为了避免每次有写命令都直接写入硬盘，导致硬盘IO成为Redis负载的瓶颈。
2. 文件写入(write)和文件同步(sync)：根据不同的同步策略将aof_buf中的内容同步到硬盘。
3. 文件重写(rewrite)：定期重写AOF文件，达到压缩的目的。

### appendfsync参数

**AOF缓存区的同步文件策略由参数appendfsync控制**

1. always
  * 命令写入aof_buf后立即调用系统fsync操作同步到AOF文件，fsync完成后线程返回。这种情况下，每次有写命令都要同步到AOF文件，**硬盘IO成为性能瓶颈**。

2. no
  * 命令写入aof_buf后调用系统write操作，不对AOF文件做fsync同步；同步由操作系统负责，通常同步周期为30秒。这种情况下，文件同步的时间不可控，且缓冲区中堆积的数据会很多，数据安全性无法保证。

3. everysec
  * 命令写入aof_buf后调用系统write操作，write完成后线程返回；fsync同步文件操作由专门的线程每秒调用一次。**everysec是前述两种策略的折中，是性能和数据安全性的平衡，因此是Redis的默认配置，也是我们推荐的配置**。


### 文件重写(rewrite)

**文件重写是指定期重写AOF文件，减小AOF文件的体积**

**AOF重写是把Redis进程内的数据转化为写命令，同步到新的AOF文件；不会对旧的AOF文件进行任何读取、写入操作**

关于文件重写需要注意的另一点是：对于AOF持久化来说，文件重写虽然是强烈推荐的，但并不是必须的；即使没有文件重写，数据也可以被持久化并在Redis启动的时候导入；因此在一些实现中，会关闭自动的文件重写，然后通过定时任务在每天的某一时刻定时执行。


文件重写之所以能够压缩AOF文件的原因

1. 过期的数据不再写入文件

2. 无效的命令不再写入文件
  * 如有些数据被重复设值(set mykey v1, set mykey v2)、有些数据被删除了(sadd myset v1, del myset)等等

3. 多条命令可以合并为一个
  * 如sadd myset v1, sadd myset v2, sadd myset v3可以合并为sadd myset v1 v2 v3。

#### 文件重写的触发

1. 手动触发
  * 直接调用bgrewriteaof命令，该命令的执行与bgsave有些类似：都是fork子进程进行具体的工作，且都只有在fork时阻塞。

2. 自动触发
    **根据auto-aof-rewrite-min-size和auto-aof-rewrite-percentage参数，以及aof_current_size和aof_base_size状态确定触发时机**。
	1. auto-aof-rewrite-min-size
		* 执行AOF重写时，文件的最小体积，默认值为64MB。
	2. auto-aof-rewrite-percentage
		* 执行AOF重写时，当前AOF大小(即aof_current_size)和上一次重写时AOF大小(aof_base_size)的比值。

**只有当auto-aof-rewrite-min-size和auto-aof-rewrite-percentage两个参数同时满足时，才会自动触发AOF重写，即bgrewriteaof操作。**

#### 文件重写的流程

重写流程图
![](https://ws1.sinaimg.cn/large/9f0d15f3ly1g5hu5nkyvkj20aj09laab.jpg)

1. Redis父进程首先判断当前是否存在正在执行 bgsave/bgrewriteaof的子进程，如果存在则bgrewriteaof命令直接返回，如果存在bgsave命令则等bgsave执行完成后再执行。
2. 父进程执行fork操作创建子进程，这个过程中父进程是阻塞的。
3. 
	1. 父进程fork后，bgrewriteaof命令返回”Background append only file rewrite started”信息并不再阻塞父进程，并可以响应其他命令。**Redis的所有写命令依然写入AOF缓冲区，并根据appendfsync策略同步到硬盘，保证原有AOF机制的正确。**
	2. 由于fork操作使用写时复制技术，子进程只能共享fork操作时的内存数据。**由于父进程依然在响应命令，因此Redis使用AOF重写缓冲区(图中的aof_rewrite_buf)保存这部分数据，防止新AOF文件生成期间丢失这部分数据。也就是说，bgrewriteaof执行期间，Redis的写命令同时追加到aof_buf和aof_rewirte_buf两个缓冲区**。
4. 子进程根据内存快照，按照命令合并规则写入到新的AOF文件。
5. 
	1. 子进程写完新的AOF文件后，向父进程发信号，父进程更新统计信息，具体可以通过info persistence查看。
	2. 父进程把AOF重写缓冲区的数据写入到新的AOF文件，这样就保证了新AOF文件所保存的数据库状态和服务器当前状态一致。
	3. 使用新的AOF文件替换老文件，完成AOF重写。

### 启动时加载

1. 当AOF开启时，Redis启动时会优先载入AOF文件来恢复数据。
2. 当AOF开启，但AOF文件不存在时，即使RDB文件存在也不会加载。

#### 文件校验

1. Redis载入AOF文件时，会对AOF文件进行校验，如果文件损坏，则日志中会打印错误，Redis启动失败。
2. 如果是AOF文件结尾不完整(机器突然宕机等容易导致文件尾部不完整)，且aof-load-truncated参数开启，则日志中会输出警告，Redis忽略掉AOF文件的尾部，启动成功。aof-load-truncated参数默认是开启的。

#### 伪客户端

因为Redis的命令只能在客户端上下文中执行，而载入AOF文件时命令是直接从文件中读取的，并不是由客户端发送；**因此Redis服务器在载入AOF文件之前，会创建一个没有网络连接的客户端**，之后用它来执行AOF文件中的命令，命令执行的效果与带网络连接的客户端完全一样。

### AOF常用配置总结

1. appendonly no：是否开启AOF
2. appendfilename "appendonly.aof"：AOF文件名
3. dir ./：RDB文件和AOF文件所在目录
4. appendfsync everysec：fsync持久化策略
5. no-appendfsync-on-rewrite no：AOF重写期间是否禁止fsync；如果开启该选项，可以减轻文件重写时CPU和硬盘的负载（尤其是硬盘），但是可能会丢失AOF重写期间的数据；需要在负载和安全性之间进行平衡
6. auto-aof-rewrite-percentage 100：文件重写触发条件之一
7. auto-aof-rewrite-min-size 64mb：文件重写触发提交之一
8. aof-load-truncated yes：如果AOF文件结尾损坏，Redis启动时是否仍载入AOF文件

## 方案选择与常见问题

### RDB和AOF的优缺点

1. RDB持久化
  1. 优点：RDB文件紧凑，体积小，网络传输快，适合全量复制；恢复速度比AOF快很多。当然，与AOF相比，RDB最重要的优点之一是对性能的影响相对较小。
  2. 缺点：RDB文件的致命缺点在于其数据快照的持久化方式决定了必然做不到实时持久化，而在数据越来越重要的今天，数据的大量丢失很多时候是无法接受的，因此AOF持久化成为主流。此外，RDB文件需要满足特定格式，兼容性差（如老版本的Redis不兼容新版本的RDB文件）。

2. AOF持久化
  1. 优点：于支持秒级持久化、兼容性好。
  2. 缺点：是文件大、恢复速度慢、对性能影响大。

### 策略选择等其他问题参见原文

> https://www.cnblogs.com/kismetv/p/9137897.html


refer

> https://www.cnblogs.com/kismetv/p/8654978.html