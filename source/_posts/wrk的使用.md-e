---
title: wrk的使用
date: 2021-06-10 14:21:23
tags: [lua, linux]
categories: application
---

## wrk
1. github项目地址： https://github.com/wg/wrk
2. 可以配合lua脚本使用

<!-- more -->

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

### wrk跟lua脚本配合使用
1. 引入lua脚本，可以使压测的行为更加复杂，比如给每个线程创建不同的body，进行压测。
2. 通过-s可以指定传入的脚本名称。

### lua脚本中可以获取到wrk的变量
1. scheme 
2. host
3. port
4. method
5. path
6. headers
7. body
8. thread

```lua
function setup(thread)
    print(thread.method)
    print(wrk.scheme)
    print(wrk.method)
    print(wrk.host)
    print("path", wrk.path)
    print("headers", #wrk.headers)
    print("body", wrk.body)
end

```

#### wrk运行阶段
wrk的运行可以分为三个阶段，在这三个阶段可以通过lua编写对应的方法，来达到"嵌入"行为的目的。

1. **Step阶段**，该阶段解析了被压测的地址，并且初始化好了所有的线程，处于等待开始阶段，所以这个阶段编写的脚本的执行开销，其实是不会算入结论输出里面的。在lua脚本定义**setup**函数，传入`thread`参数。

    thread也有自己的一些属性和方法
    * thread.addr，获取当前thread访问的地址，以ip:port的形式
    * thread:set(key, value)，在线程里面设定key,value
    * thread:get(key)，指定key获取thread环境里的对应的value
    * thread:stop()，暂停thread


    ```lua
    function setup(thread)
    
    end
    ```
2. **Running阶段**，该阶段又可以细分为四个阶段。
   
    * **init阶段**，该阶段可以接受wrk命令传入的额外参数，只需要将额外参数跟随在最末尾，空格分隔即可。在lua脚本定义**init**函数，传入args参数，**当有额外参数传入的时候，args为一个table**，可以使用pairs迭代获取其value。
      
      ```lua
        function init(args)
            for i,v in pairs(args)
            do
              print(i,v)
            end
        end
      ```
      指定脚本后传入参数打印能看到如下输出,index为0的是压测地址，1为bb，2为cc
      ```shell
        huangyisan@k3s-master:~/learn-lua/wrk$ wrk -t1 -c1 -d1s --timeout 1s -s init.lua  --latency https://www.baidu.com bb cc
        0	https://www.baidu.com
        1	bb
        2	cc
        Running 1s test @ https://www.baidu.com
          1 threads and 1 connections
          .....
          ....
          ...
          ..
          .
      ```
    
    * **delay阶段**,该阶段表示两次请求延迟间隔，函数返回一个毫秒为单位的数字。在lua脚本定义**delay**函数，返回数字，该数字单位为**毫秒**。
    
      ```lua
        function delay()
          return 200
        end
      ```
      脚本表示延迟间隔为200ms,当指定延迟脚本和不指定延迟脚本得到的结果很明显，指定了延迟脚本的结果**Requests/sec**明显下降了。
      ```shell
        huangyisan@k3s-master:~/learn-lua/wrk$ wrk -t1 -c2 -d2s  https://www.baidu.com 
        Running 2s test @ https://www.baidu.com
          1 threads and 2 connections
          Thread Stats   Avg      Stdev     Max   +/- Stdev
            Latency    85.89ms   25.21ms 185.38ms   77.78%
            Req/Sec    23.17      7.68    40.00     83.33%
          44 requests in 2.01s, 673.82KB read
        Requests/sec:     21.91
        Transfer/sec:    335.56KB
        
        huangyisan@k3s-master:~/learn-lua/wrk$ wrk -t1 -c2 -d2s -s delay.lua https://www.baidu.com 
        Running 2s test @ https://www.baidu.com
          1 threads and 2 connections
          Thread Stats   Avg      Stdev     Max   +/- Stdev
            Latency    53.43ms    8.35ms  81.61ms   92.86%
            Req/Sec     7.00      2.33    10.00     62.50%
          14 requests in 2.01s, 214.40KB read
        Requests/sec:      6.96
        Transfer/sec:    106.53KB

      ```
    
    * **request阶段**，该阶段可以对请求进行构造，比如修改请求头，修改body等，最后需要返回**wrk.format()**，建议将一些可以不在该阶段的修改代码放到init()方法里面，让request腾出更多的时间去完成压测请求。一个完整的wrk.format()函数传入的参数**依次**对应为`method, path, headers, body`。在lua脚本里面定义**request**函数函数即可。如果在function里面并不是修改全局wrk的属性，则需要传入，否则可以不传入，比如下面wrk.method被修改了，则不需要传入，而path为函数内本地属性，需要传入。
      
      ```lua
        function request()
          path = "/?x"
          wrk.method = "POST"
        return wrk.format(nil,path)
        end
      ```
    * **response阶段**，该阶段可以处理请求返回的status,headers,body。在lua脚本中定义**response**函数，传入的参数分别为`status,headers,body`。
      
      ```lua
        function response(status,headers,body)
          for _,v in pairs(headers)
            do
              print(v)
          end
          print(status)
        end
      ```
3. **Done阶段**，该阶段以table的形式接受结果，以及表示每个请求延迟和每线程请求率的两个统计对象，此时可以根据自己的算法需求来编写最后的输出结果。在lua脚本中定义**done**函数，传入参数分别为`summary, latency, requests`。

  其对象有如下这些:
  * latency.min 最小值
  * latency.max 最大值
  * latency.mean 平均值
  * latency.stdev 标准偏差
  * latency:percentile(num) 指定数字百分比的数值
  * latency(i) : raw value and count

  summary:
  ```
    summary = {    
        duration = N,  -- run duration in microseconds    
        requests = N,  -- total completed requests    
        bytes    = N,  -- total bytes received    
        errors   = {      
           connect = N, -- total socket connection errors      
           read    = N, -- total socket read errors      
           write   = N, -- total socket write errors      
           status  = N, -- total HTTP status codes > 399      
           timeout = N  -- total request timeouts    
       }  
    }
  ```

  自定义输出lua脚本
  ```lua
    function done(summary, latency, requests)
       io.write("------------------------------\n")
       for _, p in pairs({ 50, 90, 99, 99.999 }) do
          n = latency:percentile(p)
          io.write(string.format("%g%%,%dms\n", p, n/1000))
       end
       io.write("--------error requets count--------\n")
       print(summary["errors"]["status"])

    end

  ```

  ```shell
    huangyisan@k3s-master:~/learn-lua/wrk$ wrk -t1 -c2 -d2s -s done.lua --latency https://www.baidu.com 
    Running 2s test @ https://www.baidu.com
      1 threads and 2 connections
      Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency    86.47ms   17.21ms 130.38ms   79.07%
        Req/Sec    22.26      8.53    40.00     78.95%
      Latency Distribution
         50%   86.63ms
         75%   96.13ms
         90%  101.42ms
         99%  130.38ms
      43 requests in 2.01s, 658.52KB read
    Requests/sec:     21.39
    Transfer/sec:    327.57KB
    ------------------------------
    50%,86ms
    90%,101ms
    99%,130ms
    99.999%,130ms
    --------error requets count--------
    0

  
  ```
  自定义了输出，打印了**50,  90,  90,  99.999**百分比的标准偏差，同时打印了请求错误的数量。

### wkr另外两个函数

`function wrk.lookup(host, service) `
返回主机地址和服务列表。

`function wrk.connect(addr) `
连接指定addr地址，如果能连接，则返回`true`，反之则`false`。

这两个函数并不在生命周期中，但可以在生命周期阶段被调用，例如:https://github.com/wg/wrk/blob/master/scripts/addr.lua


refer
> https://medium.com/@felipedutratine/intelligent-benchmark-with-wrk-163986c1587f
> https://programmer.ink/think/quick-start-for-the-http-pressure-tool-wrk.html