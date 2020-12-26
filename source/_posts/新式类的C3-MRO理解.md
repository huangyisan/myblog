---
title: 新式类的C3 MRO理解
date: 2018-12-20 23:07:44
tags: python3
---

## 新式类
**python2.3以及之后的版本遵循的原则：C3 MRO**

其遵循的原则为：
`一个类同时继承的类中，如果没有共同父类，则往最左的类的父类查询；如果存在共同父类，则从左到右查询。`

<!-- more -->

自省方法`__mro__`

## 存在共同父类的情况

```
class D(object): pass
class E(object): pass
class F(object): pass
class B(D, E): pass
class C(D, F): pass
class A(B, C): pass
print(A.__mro__)

(<class '__main__.A'>, <class '__main__.B'>, <class '__main__.C'>, <class '__main__.D'>, <class '__main__.E'>, <class '__main__.F'>, <class 'object'>)
```

顺序解释:
**这边需要注意的是B和C有相同的父类，所以B查询后直接查询的C。**

```
查询关系
D --> D,object
E --> E,object
F --> F,object

B --> B, D, E, ...., object
C --> C, D, F, ...., object
A --> A. B, C, ...., object
  将B和C带入后得到
  --> A, (B, D, E, ..., object), (C,D,F, ..., object)
  B和C存在共同的父类，D，所以B和C是同一级别，查询顺序是A, B, C, 然后D,
  --> A, B, C, D (E, ..., object), (F, ..., object) 
  --> A, B, C, D, E, F, object
```

## 不存在共同父类的情况

```
class g(object): pass
class f(object): pass
class h(object): pass
class i(object): pass
class e(object): pass
class d(h,i): pass
class b(d,e): pass
class c(f,g): pass
class a(b,c): pass
print(a.__mro__)

(<class '__main__.a'>, <class '__main__.b'>, <class '__main__.d'>, <class '__main__.h'>, <class '__main__.i'>, <class '__main__.e'>, <class '__main__.c'>, <class '__main__.f'>, <class '__main__.g'>, <class 'object'>)
```

顺序解释：
**因为b和c不存在相同的父类，所以查询b查不到后直接查询b的父类。**

```
查询关系：
g --> g, object
f --> f, object
h --> h, object
i --> i, object
e --> e, object

b --> b, d, e, ..., object
c --> c, f, g, ..., object
d --> d, h, i, ..., object

a --> a, b, c, ..., object
  将B和C带入后得到
  --> a, (b, d, e, ..., object), (c, f, g, ..., object)
  将b带入后得到
  --> a, (b, (d, h, i, ..., object), e, ..., object), (c, f, g, ..., object)
  b和c没有共同的父类，所以直接查询了d，d后，查询他的继承，h，因为h最顶了，所以开始依次返回，查询其平级的i，然后折回到b中右边的e,然后再次返回到a中右边的c，然后查询c中的f,发现到顶了，则查询其平级的g，然后依次退出，发现直接查询完了全部，则查询object。
```