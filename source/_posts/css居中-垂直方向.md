---
title: css居中-垂直方向
date: 2020-03-18 12:55:12
tags: [css, html]
---



[查看如何水平居中](https://kirakirazone.com/2020/03/14/css居中-水平方向/)



**垂直居中相对比较复杂**



## 行级元素(inline inline-*类型)垂直居中

### 单行情况

1. 有时候看似居中了，其实是上下padding预留了相同的空间，所以中间的内容居中了。

<!-- more -->

<iframe height="265" style="width: 100%;" scrolling="no" title="Centering text (kinda) with Padding" src="https://codepen.io/huangyisan/embed/abOKwOq?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/abOKwOq'>Centering text (kinda) with Padding</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



2. 不用padding，则可以将`line-height`和`height`的值设置相等。该方法比较常用。



<iframe height="265" style="width: 100%;" scrolling="no" title="Centering a line with line-height" src="https://codepen.io/huangyisan/embed/yLNEXOg?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/yLNEXOg'>Centering a line with line-height</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



### 多行情况

1. 多行情况也可以用padding填充等量的上下空间。如果不采用这种方式，则可以使用如下模拟table或者直接table元素的方式。
   * 文字放到table里面进行处理。
   * 使用css，模拟其他元素为table，来达到类似table的效果，但如果用了后者，则需要给`vertical-align: middle`属性。



<iframe height="265" style="width: 100%;" scrolling="no" title="Centering text (kinda) with Padding" src="https://codepen.io/huangyisan/embed/ExjRXgQ?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/ExjRXgQ'>Centering text (kinda) with Padding</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



2. 如果不用table方法，可以使用flexbox的方法。将内容放到一个flex里面，然后采用column的排列方式，并且给`justify-content: center;`属性居中。**并且父元素要有一个高度**。

<iframe height="265" style="width: 100%;" scrolling="no" title="Vertical Center Multi Lines of Text with Flexbox" src="https://codepen.io/huangyisan/embed/oNXywEV?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/oNXywEV'>Vertical Center Multi Lines of Text with Flexbox</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



3.  如果上面table和flex方式都不使用，则可以使用一种叫做“ghost element”的技术。在容器内设置一个**全高度**的伪元素，且**让文字内容垂直对齐**。

<iframe height="265" style="width: 100%;" scrolling="no" title="Ghost Centering Multi Line Text" src="https://codepen.io/huangyisan/embed/zYGazaL?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/zYGazaL'>Ghost Centering Multi Line Text</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



## 块级元素垂直居中

1. 待设定元素**高度已知**的情况下，可以使用绝对定位配合负margin-top的方式实现。**这种方式，即便缩放父元素高度，子元素还是属于居中状态。**

<iframe height="265" style="width: 100%;" scrolling="no" title="Center Block with Fixed Height" src="https://codepen.io/huangyisan/embed/vYOrJWy?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/vYOrJWy'>Center Block with Fixed Height</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



2. 待设定元素**高度未知**情况下，可以使用`transform: translateY(-50%)`来处理居中。**这种方式，即便缩放子元素高度，也是能保持居中的。**

<iframe height="265" style="width: 100%;" scrolling="no" title="Center Block with Unknown Height" src="https://codepen.io/huangyisan/embed/RwPJZQK?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/RwPJZQK'>Center Block with Unknown Height</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



3. 如果**不考虑缩放**的时候需要居中，则可以使用table或者用css来达到table的方式来实现。

<iframe height="265" style="width: 100%;" scrolling="no" title="Center Block with Table Stretch" src="https://codepen.io/huangyisan/embed/dyoKzgp?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/dyoKzgp'>Center Block with Table Stretch</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



4. 也可以用flex布局来实现，和行级元素垂直居中思想一致。

<iframe height="265" style="width: 100%;" scrolling="no" title="Center Block with Unknown Height with Flexbox" src="https://codepen.io/huangyisan/embed/eYNKEQw?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/eYNKEQw'>Center Block with Unknown Height with Flexbox</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>



5. flex布局如果父元素不给`justify-content: center`属性，则可以在子元素上添加`margin: auto`来实现居中效果。

<iframe height="265" style="width: 100%;" scrolling="no" title="Center Block with Unknown Height with Flexbox" src="https://codepen.io/huangyisan/embed/eYNKEbw?height=265&theme-id=dark&default-tab=css,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/huangyisan/pen/eYNKEbw'>Center Block with Unknown Height with Flexbox</a> by huangyisan
  (<a href='https://codepen.io/huangyisan'>@huangyisan</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>





ref:

> https://css-tricks.com/centering-css-complete-guide/