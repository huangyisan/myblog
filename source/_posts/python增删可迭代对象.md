---
title: python增删可迭代对象
date: 2019-03-08 10:45:38
tags: python3
---

## 问题描述
* 直接迭代对象删除列表中所有的数字4。

```
w = [1,2,3,4,4,5,6]
for i in w:
    if i == 4:
        w.remove(i)
print(w)

[1, 2, 3, 4, 5, 6]
```

输出结果中，并没有删除所有的数字4。

* 使用len()方式删除列表中所有的数字4。

```
w = [1,2,3,4,4,5,6]
for i in range(len(w)):
    if w[i] == 4:
        w.remove(w[i])
print(w)


IndexError: list index out of range
```

出现`IndexError`错误。

## 产生原因
* 第一种是因为数组长度变小，迭代时候，指向出现了偏差，使用调试模式就能发现，当删除第一个"4"后，指针指向了第二个4，然后从第二个4开始迭代，此时跳过了第二个4的存在。

* 第二种是因为数组长度变小了，但len()记录的长度没变，所以导致了后面迭代的时候out of index。

## 解决方法
**如果能保证迭代的时候的对象不会因为原对象的改变而改变，就可以解决，也就是说对原对象进行copy，而不是引用。**

列举两种处理方法：

1. 使用[:]的方式
```
w = [1,2,3,4,4,5,6]
for i in w[:]:
    if i == 4:
        w.remove(i)
print(w)

[1, 2, 3, 5, 6]
```

2. 使用deepcopy的方式
```
import copy

w = [1,2,3,4,4,5,6]

for i in copy.deepcopy(w):
    if i == 4:
        w.remove(i)
print(w)


[1, 2, 3, 5, 6]
```