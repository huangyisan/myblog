---
title: True or False
date: 2018-12-18 00:12:33
tags: python3
---

## 链式比较

先来看一段代码:

```
>>> 2 in [1,0] == False
False
```

起先我认为输出的结果是True，因为 2 in [1,0] 为False，接着False == False 返回的是True。

后来发现，这个其实是**链式比较(chained comparisons)**，这种比较法，常见的为类似1<2<3这种，能立马反应过来，其实质为 1<2 and 2<3。
所以2 in [1,0] == False的本质其实为**(2 in [1,0]) and ([1,0] == False)**，很显然，前面的返回为False，后面的返回也为False，False and False的结果为False，所以最终得到的结果为False。

如下比较符号进行组合，都为链式比较
"<" | ">" | "==" | ">=" | "<=" | "<>" | "!=" | "is" ["not"] | ["not"] "in"
> https://docs.python.org/2/reference/expressions.html#comparisons


## 空字符串

代码如下：

```
>>> "" in "abc"
True
```

**空字符串始终被视为任何其他字符串的子字符串**，所以其返回为True。
**字符串的比较等价于find()方法，x in y 等价于y.find(x) != -1。**
当find()执行结果为-1的时候，表示x不是y的子字符串，反之，则x为y的子字符串。空字符串的执行结果如下:

```
>>> "abc".find('') != -1
True
```

> https://docs.python.org/3/reference/expressions.html#membership-test-operations