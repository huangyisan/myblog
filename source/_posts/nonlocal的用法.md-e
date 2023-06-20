---
title: nonlocal的用法
date: 2019-02-20 22:41:38
tags: python3
---

## 作用
**nonlocal允许对嵌套的函数作用域中的名称进行赋值，并且把这样的名称的作用域查找限制在嵌套的函数内。**
**nonlocal限制查找在嵌套的函数域内，且可以在函数域内进行赋值修改。**

<!-- more -->

## 例子

```
def tester(start):
    state = start
    def nested(label):
        print(label,state)
    return nested

F=tester(0)
F('spam')
F('ham')

执行结果为
spam 0
ham 0
```

函数nested中print方法内的state变量引用了上一层tester函数中的state。

如果仅仅是引用变量，则不会出现问题，若是不使用nonlocal情况下对`变量进行赋值操作`，则出现报错:

```
def tester(start):
    state = start
    def nested(label):
        print(label,state)
        state += 1   # 对state变量进行了赋值操作，在nested函数中并没有单独定义state变量。
    return nested

F=tester(0)
F('spam')
F('ham') 

报错如下：
huangyisan:~/Desktop/Python_project/Mage_edu $ python3 nonlocalfunc.py
Traceback (most recent call last):
  File "nonlocalfunc.py", line 18, in <module>
    F('spam')
  File "nonlocalfunc.py", line 13, in nested
    print(label,state)
UnboundLocalError: local variable 'state' referenced before assignment
```

**state因为在nested中没有被定义，所以无法被赋值，但可以引用上一层tester函数。**

如果要定义，则需要用nonlocal函数对其进行声明：
```
def tester(start):
    state = start
    def nested(label):
        nonlocal state
        print(label,state)
        state += 1
    return nested

F=tester(0)
F('spam')
F('ham')

执行结果：
spam 0
ham 1
```

## 边界情况
1. nonlocal对象必须已经在一个嵌套的def作用域中被赋值过，否则会报错。(global则不需要预先对变量进行赋值。)

报错代码如下：
```
def tester(start):
    def nested(label):
        nonlocal state  # 在nested外层函数，也就是tester函数中并没有对state变量进行赋值。
        state = 1
        print(label,state) 
        state += 1
    return nested

F=tester(0)
F('spam')
F('ham') 
```

**因为在state被nonlocal处理之前并没有对state进行赋值！**

2. nonlocal只会在嵌套def的作用域内查找，查找范围永远不会出def作用域范围，即便在最外层全局有了定义这个变量，也不会去查找。如果要去全局变量查询，则使用global。

3. nonlocal查询会`逐级往上`查询，查询到一个`立马返回`,也就是会**就近查询**。
```
state = 0
def tester(start):
    state = 1
    def cisco(middle):
        state = 2
        def nested(label):
            nonlocal state
            print(label, state)
        return nested
    return cisco

F=tester(0)
F(1)('spam')

输出结果为
spam 2
```

因为在cisco这个函数中已经存在了state=2的赋值，所以不会再查询cisco上一层tester中的state。**就近返回了state=2。**