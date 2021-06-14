---
title: gitlab cicd的使用01 -- 环境部署和demo运行
date: 2021-06-14 11:23:18
tags: [gitlab, cicd]
categories: application
---


## 前言

17年那会当时选型gitlab cicd或者jenkins做持续集成，因为不需要重复造轮子，就用了gitlab cicd，这几天重温文档，看到了gitlab-ci更新了相当多的feature，所以趁着端午期间重新回顾下，并且记录下一些feature的使用。

<!-- more -->

## gitlab-runner

1. gitlab的cicd是通过gitlab-runner进行实现的。
2. gitlab-runner一般是建议部署在和gitlab处于不同的服务器上。
3. gitlab-runner可以通过docker或者本地二进制文件的方式进行部署。详细部署过程不赘述，可以查看文末的refer，我的环境是使用二进制方式部署的。

### 让gitlab-runner连接gitlab

既然安装了gitlab-runner，那怎么才能让gitlab-runner连接到gitlab，从而执行gitlab派发的任务呢，就需要对gitlab-runner进行配置。

配置的关键主要有两个参数，`Register url`和`registration token`，这两个参数可以在gitlab的Admin Area页面下的Runners页面找到。

在gitlab-runner机器上执行`gitlab-runner register`命令，就会出现交互式输入，填写`Register url`, `Registration token`,`tag`,`executor`等信息后，就可以在刚才Admin Area的Runners页面看到已经注册了的gitlab-runner了。(后面我又添加了一个**tag为shared**的runner，执行器为docker)

![gitlab-runner注册页面](https://image.kirakirazone.com/image/gitlab-runner-register.jpg)

有关`executor`的信息，当前支持这些，`docker-ssh+machine, kubernetes, custom, docker, parallels, ssh, virtualbox, docker+machine, docker-ssh, shell`，我使用过的有docker和shell，前者为将pipeline置于docker中进行运行，后者则在本机环境进行运行pipeline定义的内容。

### gitlab-runner的几种状态
1. **shared** 该状态下的gitlab-runner可以让任何项目的pipeline运行使用。
2. **group** 
3. **specific** 只能让某个指定的项目使用该runner，**如果你将一个shared runner变更为specific，该过程不可逆**
4. **locked** 任何项目都不可以使用该runner
5. **paused** 无法使用的runner

### 尝试运行一个小的demo
1. 要运行pipeline，则需要在仓库里面创建.gitlab-ci.yml文件，并且定义其pipeline内容。
2. 将代码提交到仓库，自动触发pipeline运行构建。
3. pipeline内容
  ```yaml
  helloworld:
  tags:
    - shared
  stage:
    build
  script:
    echo "hello world"

  ```
4. 进入项目**CI/CD** -> **Pipeline**就能看到刚刚执行的pipeline了。点击进去还能看到详细步骤。

![](https://image.kirakirazone.com/image/pipeline-excute-01.png)



![](https://image.kirakirazone.com/image/pipeline-excute-02.png)




refer:
> https://docs.gitlab.com/runner/install/linux-manually.html
> 
