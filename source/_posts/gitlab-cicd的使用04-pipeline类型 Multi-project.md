---
title: gitlab cicd的使用04 -- pipeline类型 Multi-project
date: 2021-06-15 23:15:34
tags: [gitlab, cicd]
categories: application
---


## Pipeline Multi-project

1. Multi-project类型可以让你当前的pipeline触发另外一个项目的pipeline运行，使用关键字`trigger`

<!-- more -->

### Multi-project类型解决的问题

当两个或者多个project存在相互关系，但又因为.gitlab-ci.yml文件是分开放置，所以用Multi-project的方式可以做project pipeline的调用。



pipeline之间还可以进行变量的传递。



### Multi-project类型需求场景
1. 假设存在project today和yesterday。
2. 运行today的pipeline后触发yesterday的pipeline。

   

### Multi-project类型pipeline编写

1. today project

   ```yaml
   stages:
       - build
       - deploy
       - yesterday_trigger
   
   today_build:
       tags:
           - shared
       stage:
           build
       script:
           - echo "this is today project build"
   
   today_deploy:
       tags:
           - shared
       stage:
           deploy
       script:
           - echo "this is today project deploy"
   
   trigger_yesterday:
       # 使用variable指定环境变量，可以将该变量downstream到被trigger的pipeline
       variables:
           ENVIRONMENT: today
       # 这个步骤并不需要指定tag，因为其只是为了触发yesterday项目
       stage:
           yesterday_trigger
       trigger:
           # yesterday项目为http://192.168.65.135/root/yesterday.git, 所以为root/yesterday
           project: root/yesterday
           # 触发构建的分支为master
           branch: master
           # 这个表示，如果下游失败了，则表示该trigger_yesterday job也失败，如果成功了，则表示trigger_yesterday也成功。如果取消了该条配置，则下游失败与否和当前job无关。
           strategy: depend
   ```



2. yesterday project

   ```yaml
   stages:
       - build
       - deploy
   
   yesterday_build:
       tags:
           - shared
       stage:
           build
       script:
           - echo "this is yesterday project build"
   
   yesterday_deploy:
       tags:
           - shared
       stage:
           deploy
       script:
           - echo "this is yesterday project deploy"
           # $ENVIRONMENT从today传递过来，所以会打印出来
           - echo "$ENVIRONMENT"
   
   ```



3. today project的pipeline就会出现**Downstream**的图，示意触发了yesterday项目。

   ![](https://image.kirakirazone.com/image/mulit-pipeline.png)

refer:

> https://docs.gitlab.com/ee/ci/multi_project_pipelines.html
