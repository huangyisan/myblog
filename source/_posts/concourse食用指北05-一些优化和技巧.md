---
title: concourse食用指北05-一些优化和技巧
date: 2020-10-26 22:45:32
tags: [concourse, linux]
categories: application
---

### 使用vscode编辑器

pipeline的yaml配置文件中，配置参数需要遵循上下文。倘若只根据官方文档列出来的去编写，可能会因为配置参数的缩进错误，放置层级的错误从而不断的修改，在没有完全上手的阶段，效率会比较底下。

可以尝试使用vscode，vscode有专门针对concourse pipeline配置的扩展，使用后会自动层级对齐，补全，错误提示等功能，极大提升编写效率。

直接在"扩展"里面搜索concourse ci pipeline editor, 安装完毕后，对于如下规则的yml文件就会默认启用插件功能。
```
**/*pipeline*.yml | **/pipeline/*.yml : activates support for editing pipelines
**/tasks/*.yml | **/*task.yml : activates support for editing tasks.
```

<!-- more -->

### 镜像的制作

因为concourse运行的每一个task都是出于容器中，所以如果想快速的集成或者部署，那么可以控制一下容器的大小，毕竟如果一个容器的空间很大好几个G，那么拉取镜像就占用了不少时间。所以我个人建议，不采用大一桶的容器，容器尽量精简，只对task需要的功能进行添加。

### 并行执行任务

一些例如get获取镜像，代码等独立任务如果可以并行执行，则进行并行执行，这样可以提升效率。而且并行执行的编写也非常简单，只需要将任务定义在parallel同一层级下面即可。

### 添加一些重试机制

拉取镜像也好，推送镜像也好，难免会因为网络的问题导致任务失败，concourse pipeline配置里面可以添加`attempt`参数，指定重试次数，当失败的时候，则自动进行重试。

### 设置超时

防止一些job因特殊原因一直处于运行状态，比如资源不足从而编译打包镜像变得异常缓慢，此时可以对job设置`timeout`参数，预估一个大致能完成的时间，超过该时间，则直接job失败。

### 相同的task进行抽取

有些task执行的行为相似，可能只是部分参数不一样，或者`input`，`output`不同，那么可以将这样的task单独抽取出来，使用file关键字对task的单独文件进行引入，然后将不一样的部分，使用`params`配置项上下文定义变量。就可以进行复用了，精简了配置。

### 将一些统一的配置进行抽取

在set-pipeline阶段，可以将一些公共配置参数进行抽取，放到一个独立的文件内，使用`var_files`配置参数就能实现，比如远端服务器地址，repo的域名等，将这些配置提取的好处是，如果将来有一天进行修改，则不需要对每个pipeline进行修改，只需要修改一个文件即可。
