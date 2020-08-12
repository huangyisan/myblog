---
title: css居中-水平方向
date: 2020-03-14 15:22:13
tags: [css, html]
---



[查看如何垂直居中](https://kirakirazone.com/2020/03/18/css居中-垂直方向/)



## 行级元素(inline inline-*类型)水平居中

* 只需要将需要水平居中的行级元素包裹在**父级块级**元素内，对父级元素设置`text-align: center;`属性即可。
* 对**inline, inline-block, inline-table, inline-flex**等属性都适用。

<p class="codepen" data-height="265" data-theme-id="dark" data-default-tab="css,result" data-user="huangyisan" data-slug-hash="YzXaRWK" style="height: 265px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;" data-pen-title="Centering Inline Elements">
  <span>See the Pen <a href="https://codepen.io/huangyisan/pen/YzXaRWK">
  Centering Inline Elements</a> by huangyisan (<a href="https://codepen.io/huangyisan">@huangyisan</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>



## 一个块级元素水平居中

* 给该块级元素width属性，并且设置margin-left和margin-right皆为auto即可。
* 如果不给width属性，则宽度填满父级元素空间。

<iframe height="265" style="width: 100%;" scrolling="no" title="Centering Single Block Level Element" src="https://codepen.io/huangyisan/embed/yLNKQMv?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/yLNKQMv'>Centering Single Block Level Element</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



## 多个块级元素水平居中

* **方法一：** 若干块级元素在同一行居中，可以给这些块级元素设定相同的display属性(但并不是每个display的属性都适合水平居中)，比如给定`inline-block`属性

<iframe height="265" style="width: 100%;" scrolling="no" title="Centering Row of Blocks" src="https://codepen.io/huangyisan/embed/qBdoLwj?height=265&theme-id=dark&default-tab=html,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/qBdoLwj'>Centering Row of Blocks</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



* **方法二：**也可以给这些块级元素采用flex布局，也就是给其**父级元素**添加`display: flex;`，然后再给`justify-content: center;`

<iframe height="265" style="width: 100%;" scrolling="no" title="Centering Row of Blocks" src="https://codepen.io/huangyisan/embed/qBdoLwj?height=265&theme-id=dark&default-tab=html,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/qBdoLwj'>Centering Row of Blocks</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>




ref:

> https://css-tricks.com/centering-css-complete-guide/