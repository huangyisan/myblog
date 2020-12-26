---
title: setdefault方法传入函数
date: 2019-02-01 17:57:44
tags: python3
---

## setdefault()方法

myvalue = dict_a.setdefault(a,b)

从dict_a中获取a的值，如果没有，则新增一个value为b，key为a的键值对。

<!-- more -->

## 案例

请求获取一个数值，如果字典中存在这个值，则从字典内获取，如果不存在，则从api函数调用。

于是用了setdefault()方法，代码大致如下:

```
dict_a = {}
for i in xxxx:
    myvalue = dict_a.setdefault(a,func_api())
    xxxxx
    xxx
```

因为func_api()函数会请求线上，调用接口。

但是实现的时候，却发现，每次对myvalue赋值的时候，都会调用线上api接口。

猜测setdefault的逻辑，即便能通过指定的key获取到value，其default行为还是被执行。

## 验证猜测

**同时也验证了字典get方法**

```
>>> def b():
...   print(2)
...   return 1
... 
>>> a_dict = {}
>>> a_dict={"a":1}
>>> a_dict.setdefault("a",b())
2
1
>>> a_dict.get("a",b())
2
1
```

虽然a_dict字典已经存在"a":1,但，依旧执行了b()

## 处理方法

先进行get，若返回为None，则进行setdefault

```
groupid = groupid_templateid_dict.get(tmp_groupname)
if groupid:
    pass
else:
    groupid = groupid_templateid_dict.setdefault(tmp_groupname,zhg.get_customer_hostgroups(name=groupname,output_data=output_data))
```


这样就避免了重复调用func的问题。

## 结论

**其实只要把函数作为另外一个函数的参数，那么当调用这个函数的的时候，被传入的函数也会调用。**