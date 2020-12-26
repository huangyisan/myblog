---
title: CSS选择器权重
date: 2019-03-05 17:41:38
tags: css
---

## CSS选择器类型

* id选择器
`#id`

```css
<div id="mySelector">this is id selector</div>

#mySelector{
    color: #ff4400;
}
```

<!-- more -->

* class选择器
`.class`

```css
<div class="myClass">this is class selector</div>

.myClass{
    color:#F10882;
}
```

* \*选择器
`\*`

```css
* {
    font-style: italic;
}
```


* 元素选择器
`element`

```css
<p>this is p</p>

p{
    color:green;
}
```

* 伪类
`:hover`

```css
<a href="https://www.baidu.com">www.baidu.com</a>

a:hover{
    background-color: #f40;
}
```

* 父子选择器
`element element`
`element>element`

```css
<div>
    <p>this is p in div</p>
</div>

div p{
    color:#ff4400;
}

div>p{
    color:green;
}
```

* 属性选择器
`[attribute=value]`

```css
<div class="myclass">this is div</div>
[class=myclass]{
    color: #ff4400;
}
```

* 组选择器
`element,element1,element2`

```css
<div>this is div</div>
<span>this is span</span>
<p>this is p</p>

div,
span,
p{
    color:yellow;
}
```

## CSS选择器优先级
优先级高的覆盖优先级低的样式。
!important > 行间样式(直接元素内写style=xxx的方式) > id > class | 属性 > 标签选择器 > 通配符
其规则其实是由选择器权重实现的。

## CSS选择器权重
权重大的覆盖权重小的，不同的选择器有不同的权重。

* !important  Infinity
* 行间样式   1000
* id        100
* class | 属性 | 伪类   10
* 标签 | 伪元素  1
* 通配符 0

**进制据说是265。**
