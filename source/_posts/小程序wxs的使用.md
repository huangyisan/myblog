---
title: 用正确的姿势动态修改小程序样式
date: 2020-03-13 19:22:13
tags: 小程序
---

## 我的小程序菜单栏点击延迟很大

1. 小程序是用uni-app写的，写完真机调试发现菜单栏点击的延迟相当厉害，几乎有一到两秒。
2. 微信开发工具的模拟界面点击没有任何的延迟感。
3. 点击菜单栏会使得当前被点击的内容添加额外的样式，字体color为红色，背景为灰色。

<!-- more -->

## 排查思路

1. 使用微信开发工具的"Audits"进行体验评分，体验分挺高的，但我自己的体验还是很差啊。

2. 翻阅网上资料，修改样式也就差不多那么几种方式，我也是这样写的，感觉没毛病呀。

3. 最小化配置，删减了所有其他相关组件，就留下了一个菜单，关联的样式也全部删掉，真机测试，还是有延迟。

4. 怀疑是自己手机的问题，于是我用了下饿了么的小程序，大受打击，同时也让朋友真机测了下，也说有延迟感觉。

5. 难道是uni-app框架的锅？行吧，我用小程序原生代码写了个菜单，点击发现的确比uniapp流畅点，但还是没有饿了么小程序那个菜单来的顺滑。

6. wdnmd，网上搜来搜去，说卡的基本上是组件过多，图片过多导致，跟我这个不太一样。

7. 就这么过去了将近3天，一直没有头绪。让我更加在意的是饿了么为什么能那么流畅？

   

## uni-app原代码

### template部分代码

```vue
<block v-for='(item,index) in foodsInfo' :key='item.category'>
	<view class='side-left-item' @click="itemClick(index)" :class="{active: index === currentIndex}">
		<text>{{item.category}}</text>
	</view>
</block>
```

### JS部分代码

```javascript
data() {
	return {
		currentIndex: 0,
	}
},
methods: {
	itemClick(index) {
		this.currentIndex = index
	}
```



## 小程序原生代码

### 视图层部分代码

```vue
<block wx:for="{{leftData}}" wx:for-item="lcai" wx:key="index">
<view bindtap="btnClick" data-index="{{index}}" class="inner {{currentIndex == index? 'active' : ''}}">{{lcai.name}}</view>
</block>
```

### 逻辑层部分代码

```javascript
Page({
  data: {
    currentIndex: 0,
  },
  btnClick: function(e) {
    var index = e.currentTarget.dataset.index;
    console.log(index)
    this.setData({
      currentIndex: index
    }) 
  },
})
    
```



### 原代码的实现方式

1. 跟网上说的基本上一致，绑定点击事件，通过判断当前元素的index和currentIndex是否相等，返回true或者false来动态添加active样式(color:red; background-color: gray;)。
2. 看着没有任何的问题，在pc端也是这么写的。



## 直到我看到了这篇文章

* 植树节晚上洗完澡一直在考虑这个问题，没有头绪，谷歌搜了下通用类的小程序优化思路。看到了如下这篇文章，才恍然大悟。

* > https://zhuanlan.zhihu.com/p/82741561



### 为什么会慢？

* 小程序的视图层(wxml)和逻辑层(js)是独立分开的。这样视图层不能运行js代码，逻辑层的js代码也不能修改视图层的dom
* 当数据更新以及事件系统只能靠线程间通讯，但跨线程通信的成本极高，一些频繁通讯的场景，触摸、滚动等。
* 一个点击行为，需要经过视图层、Native、逻辑层三者之间2个完整来回的通信，通信的耗时开销较大，用户的交互就会出现延时卡顿的情况。
* for循环对数据格式修改，也会造成逻辑层和视图层频繁通讯。



### wxs的出现

* wxs是一种被限制了的js，他可以运行在视图层。**换句话说wxs和视图层的交互不需要经过Native层**。
* 他是不可以操作dom的，因为小程序的视图层和逻辑层的分开就是为了不想用js直接操作dom。
* wxs无法直接修改业务数据，只能对当前组件的class和style处理，或者数据进行格式化。
* 如果要修改业务逻辑数据，则需要用callMethod方法。

### wxs适合的场景
* 用户交互频繁、仅需改动组件样式（比如布局位置），无需改动数据内容的场景，比如侧滑菜单、索引列表、滚动渐变等 - 数据格式处理，比如文本、日期格式化，或者国际化。

## 修改后的uni-app代码

### template部分代码

```vue
<block v-for='(item,index) in foodsInfo' :key='index'>
  <!-- 绑定多个class的方式，用数组，变量不需要加{{}}     点击事件绑定wxs中export的clickwxs-->
	<view :data-index="index" :class='["side-left-item", "inner_" + index]' @click="clickwxs.tapName">
		<text>{{item.category}}</text>
	</view>
</block>
```

### WXS部分代码

```javascript
//该代码和上面template代码为同一个文件下。
//命名为clickwxs
<script module="clickwxs" lang="wxs">
function tapName(event, ins) {
	console.log(event.currentTarget.dataset.index)
	console.log(JSON.stringify(event))
  var owner = ins.selectAllComponents('.side-left-item')
  console.log(owner)
  // 移除样式
  for (var i = 0; i < owner.length; i++) {
    owner[i].removeClass('active');
    console.log('.inner' + i)
  }
	var instance = ins.selectComponent('.inner_' + event.currentTarget.dataset.index)
	console.log(instance)
  // 添加active样式
  instance.addClass('active')
  instance.getDataset()
}
module.exports = {
  tapName: tapName
}
</script>
```



## 修改后的微信小程序原生代码

### 视图层代码

```html
<!--引入wxs-->
<wxs module="wxs" src="./index.wxs"></wxs>
<view class="container">
<view>
<scroll-view scroll-y="true" class="scroll">
<block wx:for="{{leftData}}" wx:for-item="lcai" wx:key="index">
<view bindtap="{{wxs.tapName}}" data-index="{{index}}" class="inner inner_{{index}}">{{lcai.name}}</view>
</block>
</scroll-view>
</view>
</view>
```

### wxs代码

```javascript
function tapName(event, ownerInstance) {
  // 获取所有class="inner"的组件
  var owner = ownerInstance.selectAllComponents('.inner')
  console.log(owner)
  // 清除样式
  for (var i = 0; i < owner.length; i++) {
    owner[i].removeClass('active');
    console.log('.inner_' + i)
  }
  var instance = ownerInstance.selectComponent('.inner_' + event.currentTarget.dataset.index)
  // 添加active样式
  instance.addClass('active')
  instance.getDataset()
}
module.exports = {
  tapName: tapName
}
```



## 结果

**修改完后，无论是uni-app框架的小程序，还是小程序原生的写法，点击延迟感不再有。**



## 两份代码github地址

1. > https://github.com/huangyisan/fooods  leftbuttom分支

2. > https://github.com/huangyisan/ori-fooods



refer

> https://zhuanlan.zhihu.com/p/82741561
>
> https://developers.weixin.qq.com/miniprogram/dev/framework/view/interactive-animation.html
>
> https://www.cnblogs.com/murenziwei/p/11233505.html
>
> 