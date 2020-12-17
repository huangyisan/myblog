---
title: go无缓存channel出现deadlock
date: 2020-12-17 16:15:56
tags: [go]
categories: golang
---

## 问题代码
```golang
package main

import "fmt"

func main() {
    chanStr := make(chan int)

    chanStr <-1

    a := <- chanStr
    fmt.Println(a)

}
```
1. 创建一个无缓存channel chanStr
2. 往chanStr放入int类型1
3. 从chanStr读取内容至变量a
4. 打印变量a

看着没有什么问题，逻辑也很正确，**但结果发生了报错**

```golang
fatal error: all goroutines are asleep - deadlock!

goroutine 1 [chan send]:
main.main()
```

## 产生报错的原因
[官方](https://golang.org/doc/effective_go.html#channels)在这边说明了：
1. Receivers always block until there is data to receive. (直到)
2. If the channel is unbuffered, the sender blocks until the receiver has received the value.
3. If the channel has a buffer, the sender blocks only until the value has been copied to the buffer.
4. if the buffer is full, this means waiting until some receiver has retrieved a value.