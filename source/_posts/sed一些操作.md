---
title: sed的一些操作
date: 2019-02-27 09:45:38
tags: linux
---

## 原始文件redis.conf内容：

```shell
input {
  redis {
    host => "127.0.0.1:6379"
    key => "logstash:demo"
    data_type => "list"
    codec => "json"
    type => "logstash-redis-demo"
    tags => ["logstashdemo"]
  }
}

output {
  elasticsearch {
    host => "127.0.0.1:9200"
  }

}
```
<!-- more -->

## 获取sed匹配内容的下一行

原始文件redis.conf内容:

* 思路：
若要只抓取`tags => ["logstashdemo"]`内容，则需要匹配`type => "logstash-redis-demo"`这一行内容。

* sed匹配内容下一行写法:
`sed -n '/matchString/{n;p}' filename`

```
[root@leanote ~]# sed -n '/logstash-redis-demo/{n;p}' redis.conf 
    tags => ["logstashdemo"]
```

## 替换sed匹配行内容的下一行的指定内容

* 思路：
先匹配到`tags => ["logstashdemo"]`内容，然后对该内容下一行内容`tags => ["logstashdemo"]`的`logstashdemo`改为`replacedemo`

* sed替换匹配行下一行内容写法:
`sed -i '/查询匹配的内容/{n;s/下一行内要被替换的内容/替换内容/;}' filename`

```
[root@leanote ~]# sed -i '/logstash-redis-demo/{n;s/logstashdemo/replacedemo/;}' redis.conf 
[root@leanote ~]# cat redis.conf 
input {
  redis {
    host => "127.0.0.1:6379"
    key => "logstash:demo"
    data_type => "list"
    codec => "json"
    type => "logstash-redis-demo"
    tags => ["replacedemo"]
  }
}

output {
  elasticsearch {
    host => "127.0.0.1:9200"
  }
}
```

## sed内容存在变量情况

* 方法一，将外部单引号用双引号替代
```
[root@leanote ~]# echo $beitihuan
list
[root@leanote ~]# echo $tihuan   
str
[root@leanote ~]# sed -e "/key/{n;s/${beitihuan}/${tihuan}/;}" redis.conf 
input {
  redis {
    host => "127.0.0.1:6379"
    key => "logstash:demo"
    data_type => "str"
    codec => "json"
    type => "logstash-redis-demo"
    tags => ["replacedemo"]
  }
}

output {
  elasticsearch {
    host => "127.0.0.1:9200"
  }
}
```

* 方法二，不修改外部单引号，将变量用单引号引起来
```
[root@leanote ~]# sed -e '/key/{n;s/'${beitihuan}'/'${tihuan}'/;}' redis.conf 
input {
  redis {
    host => "127.0.0.1:6379"
    key => "logstash:demo"
    data_type => "str"
    codec => "json"
    type => "logstash-redis-demo"
    tags => ["replacedemo"]
  }
}

output {
  elasticsearch {
    host => "127.0.0.1:9200"
  }
}
```

* 注意点
**如果变量存在特殊符号，比如`/`，那么此时这个符号会影响sed的分隔符，需要将sed分隔符替换成其他的。**

## sed对软连文件进行操作

**sed对`软连文件`进行操作，倘若不指定`--follow-symlinks`，则软连文件和原始文件会被拆分,原始文件不会被修改，而软连的文件会被修改，且变成一个独立文件。**

sed操作没有指定`--follow-symlinks`

```
[root@leanote conf]# ll
total 0
lrwxrwxrwx 1 root root 16 Feb 27 10:58 redis.conf -> /root/redis.conf
[root@leanote conf]# sed -i '/key/{n;s/'${beitihuan}'/'${tihuan}'/;}' redis.conf 
[root@leanote conf]# ll
total 4
-rw-r--r-- 1 root root 248 Feb 27 11:00 redis.conf
```

sed操作指定`--follow-symlinks`

```
[root@leanote conf]# sed -i --follow-symlinks '/key/{n;s/'${beitihuan}'/'${tihuan}'/;}' redis.conf
[root@leanote conf]# ll
total 0
lrwxrwxrwx 1 root root 16 Feb 27 11:02 redis.conf -> /root/redis.conf
```