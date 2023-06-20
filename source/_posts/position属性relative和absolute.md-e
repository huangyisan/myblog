---
title: position属性relative和absolute
date: 2019-03-06 19:41:38
tags: css
---

我还记得那个调整了3个多小时才把确认按钮移动到table右边的夜晚。以至于前端给我的错觉就是，我写出我的思路，但它却不这么去展现。。mmp..
至此拾起来，从把relative和absolute两个属性搞清楚开始。

<!-- more -->

## 非嵌套在标签的情形

初始代码:
```css
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <link rel="stylesheet" href="position.css">
</head>
<body>
<div class="first">class first</div>
<div class="second">class second</div>
</body>
</html>


*{
    margin: 0;
    padding: 0;
}

.first{
    width: 100px;
    height: 100px;
    background-color: #5060ff;
}

.second{
    width: 200px;
    height: 200px;
    background-color: #ff7276;
}
```

两个div挨在一起。
![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0tcqq5yyej20la0j0aam.jpg)

* relative

**添加position:relative等属性**
```
.first{
    position: relative;
    top: 50px;
    left: 50px;
    width: 100px;
    height: 100px;
    background-color: #5060ff;
}
```

蓝色背景的div根据top和left参数，位置上发生了改变。而红色div位置没有改变。
![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0tctv6lmzj20g00iy3yr.jpg)

* absolute

**添加position:absolute等属性**
```
.first{
    position: absolute;
    top: 50px;
    left: 50px;
    width: 100px;
    height: 100px;
    background-color: #5060ff;
}
```

蓝色背景div根据top和left参数，位置上发生了改变，并且红色的div位置也发生了改变，和页面的顶部左边靠紧。
![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0td19sj58j20fm0dkaaf.jpg)



## 嵌套在标签的情形

初始代码:
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <link rel="stylesheet" href="position.css">
</head>
<body>
<div class="first">
    <div class="second">
        <div class="third"></div>
    </div>
</div>
</body>
</html>


*{
    margin: 0;
    padding: 0;
}

.first{
    width: 200px;
    height: 200px;
    background-color: #5060ff;
}

.second{
    width: 100px;
    height: 100px;
    background-color: #ff7276;
}

.third{
    width: 50px;
    height: 50px;
    background-color: #ffe43e;
}
```

三个方块重叠在一起
![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0td9z1ae5j20do0dcwel.jpg)

* relative

**给third添加relative等属性**

```
.third{
    position: relative;
    top: 20px;
    left: 20px;
    width: 50px;
    height: 50px;
    background-color: #ffe43e;
}
```

黄色背景div基于原来位置根据top和left参数，位置上发生了改变。

![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0tdblwdp4j20dq0dy74a.jpg)

**再给second添加属性，去掉之前third的属性**

```
.second{
    position: relative;
    top: 30px;
    left: 30px;
    width: 100px;
    height: 100px;
    background-color: #ff7276;
}

.third{
<!--     position: relative;
    top: 70px;
    left: 70px;
 -->    width: 50px;
    height: 50px;
    background-color: #ffe43e;
}
```

黄色背景div跟随红色背景div移动。

![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0tdpkuy6uj20ds0dkt8p.jpg)

**恢复third的属性**

```
.second{
    position: relative;
    top: 30px;
    left: 30px;
    width: 100px;
    height: 100px;
    background-color: #ff7276;
}

.third{
    position: relative;
    top: 70px;
    left: 70px;
    width: 50px;
    height: 50px;
    background-color: #ffe43e;
}
```

黄色背景div在基于原来位置的基础上根据top和left参数，发生了改变。

![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0tdgy62lej20do0du0sq.jpg)


* absolute

**给third添加absolute等属性**

```
.third{
    position: absolute;
    top: 70px;
    left: 70px;
    width: 50px;
    height: 50px;
    background-color: #ffe43e;
}
```


黄色背景div根据top和left参数，发生了变化。

![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0tdvj48azj20dq0deaa2.jpg)

**再给second添加属性**

```
    position: relative;
    top: 30px;
    left: 30px;
    width: 100px;
    height: 100px;
    background-color: #ff7276;
}

.third{
    position: absolute;
    top: 70px;
    left: 70px;
    width: 50px;
    height: 50px;
    background-color: #ffe43e;
}

```

黄色背景div依据红色背景div再根据top和left参数，发生了变化。

![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0tdwx0ux4j20d00dojrd.jpg)


**去除second的属性，给first添加属性**

```
.first{
    position: relative;
    top: 70px;
    left: 70px;
    width: 200px;
    height: 200px;
    background-color: #5060ff;
}

.second{
    /*position: relative;*/
    /*top: 30px;*/
    /*left: 30px;*/
    width: 100px;
    height: 100px;
    background-color: #ff7276;
}

.third{
    position: absolute;
    top: 70px;
    left: 70px;
    width: 50px;
    height: 50px;
    background-color: #ffe43e;
}
```

黄色背景div依据蓝色背景div再根据top和left参数，发生了变化。

![](https://ws1.sinaimg.cn/large/9f0d15f3gy1g0te1vr00wj20hu0hyq30.jpg)

## 结论

* absolute
1. 脱离原来的位置(**因为脱离原来的位置，所以其他元素可能会对原有位置进行占用**)进行移动定位。
2. 如果最近有父级，则根据父级定位，如果没有，则根据文档定位(因为body是最大的父级)

* relative
1. 保留原来的位置，进行移动定位。
2. 即便存在父级，也是相对(父级元素位置变动，相对位置也会变动)原来的位置进行移动定位。

## absolute和relative配合
1. 一般父级用relative做架子参照物，子级用absolute进行定位。

## static和fixed
1. static定位为默认情况，不会参照任何元素进行定位，按照浏览器预设的配置自动排版在页面上。
2. fixed相对浏览器视窗定位，一直固定一个相同的位置，不会受到浏览器滚动条的影响。

refer
> https://www.jianshu.com/p/f946aca4d6b0