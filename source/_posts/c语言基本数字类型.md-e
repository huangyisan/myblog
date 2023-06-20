---
title: c语言基本数字类型
date: 2019-01-06 15:36:06
tags: c
---

## 基本数字类型

### 关键字

- int
- long
- short
- unsigned
- char
- float
- double
- signed
- \_Bool (c99加入的bool类型)
- \_Complex (c99加入的复数类型)
- \_Imaginary  (c99加入的虚数类型)

<!-- more -->

### 有符号整形

**有符号类型可用于表示正整数和负整数。**

* int 系统给定的基本整数类型，c语言规定int类型不小于`16位`。

* short或short int 最大的shrot类型整数小于或等于最大的int类型整数。c语言规定short类型至少占`16位`。

* long或long int 该类型可表示的整数大于或等于最大的int类型整数。c语言规定long类型至少占位`32位`。

* long long或long long int 该类型可以表示的整数大于或等于最大的long类型整数。long long 类型至少占`64位`。

**一般而言，long类型的占用内存比short类型大，int类型的宽度要和和long类型相同，要么和short类型相同。**

### 无符号整形

**无符号整形只能用于表示零和正整数，因此`无符号整形可以表示的正整数比有符号整形的大`。在整形类型前面加上关键字`unsigned`表明该类型是无符号整形。单独的unsigned相当于unsigned int。**

### 字符类型

**char类型实际上存储的是整数，而非字符。ASCII编码范围是`0~127`，所以只需要`7位`二进制数表示即可(这里不包含中文日文等特殊字符集)。char类型表示一个字符要占用`1个字节`内存，出于历史原因，一个字节通常是`8位`，但是如果要表示基本字符集，也可以是16位或更大。**

* char 字符类型的关键字，有些编译器使用有符号的char，而有些则使用无符号的char。在需要时，可以在char前面加上关键字signed或unsigned来指明，具体使用哪一种类型。

### 布尔类型

**布尔值表示`true`和`false`。c语言用1表示`true`，0表示`false`**

* \_Bool 布尔类型的关键字，c99加入。其类型为无符号int类型，所占用的个空间只要能存储0或者1即可。

### 实浮点类型(实数浮点类型)

**实浮点类型可以表示正浮点数和负浮点数。**

* float 系统基本浮点类型，可精确表示至少6位有效数字。

* double 存储浮点数的范围更大，能表示比float类型更多的有效数字(至少15位)和更大的指数。

* long long 存储浮点束的范围比double更大，能表示比double更多的有效数字和更大的指数。

### 复数和虚数浮点数

**虚数类型是可选的类型。复数的实部和虚部类型都基于`实浮点类型`来构成。**

- float \_Complex
- double \_Complex
- long double \_Complex
- float \_Imaginary
- double \_Imaginary
- long double \_Imaginary
