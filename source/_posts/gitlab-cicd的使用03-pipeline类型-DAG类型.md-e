---
title: gitlab cicd的使用03 -- pipeline类型 DAG类型
date: 2021-06-14 23:14:18
tags: [gitlab, cicd]
categories: application
---


## Pipeline DAG类型

除了最常见的Pipeline类型，按顺序执行，还存在其他类型的pipeline。
1. DAG类型，这种类型突破了传统的按顺序执行，可以直接根据依赖关系执行，使用关键字`needs`

<!-- more -->

### DAG类型解决的问题

假设把pipeline划分为三个阶段，build,test,deploy。在build阶段，存在两个job，然后test一个job，deploy也是一个job，目前build阶段的其中一个job（job_b）只是暂时编写进去，是否执行不会影响后面的test和deploy阶段。而test和deploy真正关心的是job_a，那么其实只需要job_b执行完后，就可以执行test和deploy阶段，而无需等待job_a执行完毕。

还有一种情形，比如用多端框架编写的代码，在build阶段会进行多平台编译，有IOS，有Android，有PC端，然后test阶段也存在根据不同的平台进行测试的job，此时test阶段关于IOS的测试其实只需要在build阶段IOS的job跑完即可，而无需等待另外两个端的build完成。

### DAG类型需求场景
1. 假设存在IOS, Android,PC三个端。
2. 需要各自build，并且进行测试。
3. 最后再分发到不同的平台。

### DAG类型pipeline编写

```yaml
stages:
    - build
    - test
    - deploy

ios_build:
    tags:
        - shared
    stage:
        build
    script:
        - echo "Build on ios"
        - sleep 10

android_build:
    tags:
        - shared
    stage:
        build
    script:
        - echo "Build on android"
        - sleep 30

pc_build:
    tags:
        - shared
    stage:
        build
    script:
        - echo "Build on pc"
        - sleep 50

ios_test:
    tags:
        - shared
    stage:
        test
    script:
        - echo "Test for ios"
        - sleep 10
    # 当ios_build执行完，则执行本job
    needs:
        - ios_build

android_test:
    tags:
        - shared
    stage:
        test
    script:
        - echo "Test for android"
        - sleep 20
    needs:
        - android_build

pc_test:
    tags:
        - shared
    stage:
        test
    script:
        - echo "Test for pc"
        - sleep 5
    needs:
        - pc_build

ios_deploy:
    tags:
        - shared
    stage:
        deploy
    script:
        - echo "Deploy for ios"
    # 当执行完ios_build和ios_test，则执行本job
    needs:
        - ios_build
        - ios_test

android_deploy:
    tags:
        - shared
    stage:
        deploy
    script:
        - echo "Deploy for android"
    needs:
        - android_build
        - android_test

pc_deploy:
    tags:
        - shared
    stage:
        deploy
    script:
        - echo "Deploy for pc"
    needs:
        - pc_build
        - pc_test

```

上述任务需要开启gitlab-runner的多任务，`concurrent`大于1。

pipeline运行后不再是之前的根据stages顺序执行，而是通过needs关键字指定的关系，进行执行。
![](https://assets.iostat.io/image/dag-pipeline.png)



refer:

> https://docs.gitlab.com/ee/ci/directed_acyclic_graph/
> https://about.gitlab.com/blog/2020/05/12/directed-acyclic-graph/
