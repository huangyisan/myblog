---
title: wrk的使用
date: 2021-06-10 10:17:23
tags: [lua, linux]
categories: application
---

## wrk
1. github项目地址： https://github.com/wg/wrk
2. 可以配合lua脚本使用

### wrk参数

```shell
Usage: wrk <options> <url>                            
  Options:                                            
    -c, --connections <N>  Connections to keep open   
    -d, --duration    <T>  Duration of test           
    -t, --threads     <N>  Number of threads to use   
                                                      
    -s, --script      <S>  Load Lua script file       
    -H, --header      <H>  Add header to request      
        --latency          Print latency statistics   
        --timeout     <T>  Socket/request timeout     
    -v, --version          Print version details      

```

* -c 表示并发连接数

* -d 持续时间，如果不填写，默认为10s

* -t 线程数

* -s 指定lua脚本

* -H 指定请求头

* --latency 最终输出阶段打印出latency信息

* --timeout 设置超时时间

* -v 查看工具版本

### wrk压测样例

```shell
huangyisan@k3s-master:~/learn-lua/wrk$ wrk -t1 -c3 -d1s --timeout 1s --latency https://www.baidu.com
1 Running 1s test @ https://www.baidu.com
2  1 threads and 3 connections
3  Thread Stats   Avg      Stdev     Max   +/- Stdev
4    Latency    97.57ms   33.94ms 183.80ms   76.00%
5    Req/Sec    27.75      8.01    40.00     75.00%
6  Latency Distribution
7     50%   81.64ms
8     75%  106.93ms
9     90%  153.27ms
10     99%  183.80ms
11  25 requests in 1.01s, 414.54KB read
12 Requests/sec:     24.85
13 Transfer/sec:    412.03KB

```
输出解释：
* 第一行： 表示请求https://www.baidu.com 持续1s
* 第二行： 表示1个线程3个并发连接数
* 第三行：
  * Thread Stats：表示类型字段
  * Avg：单个线程的平均值
  * Stdev：单个线程标准偏差
  * Max：单个线程最大值
  * +/- Stdev：标准偏差以百分数形式表示
* 第四行：表示请求延迟，越小越好
* 第五行：表示每秒请求数，越大越好
* 第六行：唯有在命令行加上--latency 参数才有
* 第七行至第十行：表示了延迟数据分布，50%的请求在81.64ms中完成，这里面包含了**Coordinated Omission**修正，所以延迟会比服务端打点来的大，因为其包含了用户请求发送的等待时间，具体可以参考:https://github.com/giltene/wrk2 https://zhuanlan.zhihu.com/p/43602062
* 第十一行：表示了在固定的1s内完成了25个请求，数据读取414.54KB
* 第十二行：表示所有请求的均值每秒数据，**这是一个重要的指标**。req/sec和request/sec的差别https://github.com/wg/wrk/issues/259
* 第十三行：每秒传输的数据量
