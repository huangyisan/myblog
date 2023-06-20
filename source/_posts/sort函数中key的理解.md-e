---
title: sort函数中key的理解
date: 2018-12-29 14:41:38
tags: python3
---

## sort()函数
```python
Help on method_descriptor:

sort(...)
    L.sort(key=None, reverse=False) -> None -- stable sort *IN PLACE*
(END)
```

<!-- more -->

*python3中已经取消了sort()函数中cmp参数*

python中sort()函数用来排序，其中有个key的参数，十分神奇。

我对key参数的理解是：
**这个key是构造了一个全新的对象，对这些全新的对象进行比较排序，然后再根据结果，对原先的对象进行排序。**

## 字典value排序:
比如很常用的，对一个字典进行value排序：
```
d = {1: 'c', 2:'d', 3: 'b', 4: 'a'}

def sort_value(x):
    return x[1]

print(sorted(d.items(), key=sort_value))
```

`d.items`得到dict_items([(1, 'c'), (2, 'd'), (3, 'b'), (4, 'a')])，其挨个传入到key对应的sort_value函数中，返回索引为1的值，也就是value的值，然后对这个新对象进行排序，最终以新对象排序的结果来输出d.items()的排序。

将sort_value函数写成lambda则：
```
print(sorted(d.items(), key=lambda x :x[1]))
```

## 字符串内容重新排序:
对字符串"hUangYisan6749"重新排序，要求:
1. 数字在最前面，偶数在奇数前面。
2. 字符串在数字后面，大写字母在小写字母后面。

思路：
1. 字符串挨个拆出来。
2. 构造一个元组，能够符合上述需求，然后排序的。**元组的排序是从首个元素逐一排序的，碰到首元素一样，则比第二个元素**

先确定一个通用的元组，总共是四种类型，奇数偶数，大写小写。
例：偶数，奇数，大写，小写(1,0,0,0)，比如这样就表示该字符为偶数。

**由于默认sorted排序是从小到大，所以根据需求，得写成小写，大写，奇数，偶数的方式(或者加上reverse=True)**

```
def custom_order(x):
    if x.islower():
        return 1,0,0,0,x
    if x.isupper():
        return 0,1,0,0,x
    if x.isdigit() and int(x) % 2 == 0:
        return 0,0,1,0,x
    else:
        return 0,0,0,1,x
```
当对比相同的时候，会索引+1比较，所以return不能漏掉x，因为当前面四位全部相等的时候，要比较x。

那么代码可以写成：
```
mystring = "hUangYisan6749"
def custom_order(x):
    if x.islower():
        return 1,0,0,0,x
    if x.isupper():
        return 0,1,0,0,x
    if x.isdigit() and int(x) % 2 == 0:
        return 0,0,1,0,x
    else:
        return 0,0,0,1,x

print("".join(sorted(mystring,key=custom_order)))

7946UYaaghinns
```

refer:
> http://python.jobbole.com/85025/