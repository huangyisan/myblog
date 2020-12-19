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
1. Receivers always block until there is data to receive. (直到channel内存在数据，消费端才会解除block状态)
2. If the channel is unbuffered, the sender blocks until the receiver has received the value.(如果是无buff的channel，直到消费者消费了数据，发送者才会解除block状态)
3. If the channel has a buffer, the sender blocks only until the value has been copied to the buffer.(如果是有buff的channel，那么在发送者发送数据到channel之前是block状态)
4. if the buffer is full, this means waiting until some receiver has retrieved a value.(如果buff满了，则当消费者消费数据之前，会一直等待)



产生的问题是第二点，main本身就是个goroutine，所以执行到`chanStr <-1`因为没有对应的消费者消费数据，所以被block，下面的代码也就无法执行，导致deadlock错误。



## 解决方法

将`a := <- chanStr`单独作为一个goroutine，这样就存在两个goroutine，一个main，还有一个是匿名函数，接受者和发送者在不同goroutine上，就不会出现deadlock了。



```go
package main

import "fmt"

func main() {
	chanStr := make(chan int)

	go func() {
		chanStr <- 1
	}()

	a := <- chanStr
	fmt.Println(a)

}
```



