---
title: go语言defer细节
date: 2020-06-27 11:23:33
tags: go
---

### go语言中的defer
1. 当执行defer时，会将defer后面的语句压入到单独的栈(defer栈)。
2. 当函数执行完毕后（遇到return，panic或者函数顺序执行完），在从defer栈中，按照先入后出的方式，执行。
3. 如果函数的定义为匿名返回值,则defer无法修改。
4. 如果函数的定义为具名返回值,则defer会进行修改。
5. 在函数中，需要创建资源，文件句柄，数据库连接等，在执行完毕后，关闭这些资源。go提供了defer(延时机制)。

<!-- more -->

### 顺序执行遇到defer情况

```go
package main

import "fmt"

func main() {
	sum(1,2)
}

func sum(n1 int, n2 int) {
	defer fmt.Println("第一个数为", n1) // 最后第一执行
	defer fmt.Println("第二个数为", n2) // 最后第二执行
	res := n1+n2
	fmt.Println("结果为",res)
}
```

**打印先输出fmt.Println里面的内容，接着输出最后一个defer内容，最后输出第一个defer的内容。**

```go
结果为 3
第二个数为 2
第一个数为 1
```

### defer遇到return的情况
* 当defer遇到return，在return之前，会执行defer的内容，然后再进行return。

```go
package main

import "fmt"


func sum(n1 int, n2 int) int {
	defer fmt.Println("第一个数为", n1) // 最后第一执行
	defer fmt.Println("第二个数为", n2) // 最后第二执行
	res := n1+n2
	fmt.Println("结果为",res)
	return res
}

func main() {
	sum(1,2)
}
```
**虽然有return, 但defer在栈里面，在return之前会先进行执行defer内容**

输出内容为:
```
结果为 3
第二个数为 2
第一个数为 1

```

* 但如果defer在return后面, 则不会执行defer内容，遇到return就返回了。

```go
package main

import "fmt"

func add(a int) (err error) {
	if a == 3{
		fmt.Println("我是if")
		return
	}
	defer fmt.Println("我是if return后面的defer")
	return
}

func main() {
	add(3)

}
```

输出内容只有"我是if",因为在if里面直接return了，不会触发defer。

### defer遇到匿名返回值情况

```go
package main

import (
	"fmt"
)

func foo() (string) {
	var result string
	result = "ccc"
	defer func() {
		result = "Change World" // change value at the very last moment
	}()
	return result
}

func main() {
	fmt.Println(foo())
}
```

输出为:

```go
ccc
```

因为没有指定返回值，只指定了返回类型(string)，所以defer内容无法修改result内容，打印出来的result为"ccc"。

### defer遇到具名返回值情况

```go
package main

import (
	"fmt"
)

func foo() (result string) {
	result = "ccc"
	defer func() {
		result = "Change World" // change value at the very last moment
	}()
	return result
}

func main() {
	fmt.Println(foo())
}

```

输出为:

```go
Change World

```

因为指定了返回值result， 所以defer的内容可以影响result，结果为Change World.

refer:
> https://blog.golang.org/defer-panic-and-recover
> https://golang.org/ref/spec#Defer_statements
> https://stackoverflow.com/questions/37248898/how-does-defer-and-named-return-value-work


