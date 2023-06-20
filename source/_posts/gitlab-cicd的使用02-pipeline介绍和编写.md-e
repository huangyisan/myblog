---
title: gitlab cicd的使用02 -- pipeline介绍和编写
date: 2021-06-14 15:27:18
tags: [gitlab, cicd]
categories: application
---


## .gitlab-ci.yml文件

.gitlab-ci.yml文件是gitlab cicd灵魂所在。

该文件通过yaml方式进行编写，有其特有的关键字，遵循一定的章法结构。

里面定义一个个的job，来实现pipeline具体的编排内容。

<!-- more -->

## .gitlab-ci.yml job 关键字

官方给出的关键字很多，可以查看: https://docs.gitlab.com/ee/ci/yaml/README.html

但并不是每个都常用，常用的主要有以下这几个，根据官方顺序：
* `artifacts`定义 job成功后制品的产出。
* `cache` 可对指定的路径进行缓存操作，使得在其他job里面继续使用这些缓存，比如nodejs，npm install构建生成的node_modules目录，php composer构建生成的vendor目录等。
* `image` 当gitlab-runner为docker执行器的时候，可以使用image变更某个job使用何种容器进行执行构建。
* `include` 引入其他pipeline的时候使用
* `interruptible` 定义了当新的pipeline被提交触发构建，老的正在运行的pipeline是否可以被打断的参数，为了构建一致性。
* `only` 指定某个branch或者tag有提交的时候，才构建。**only不可以使用变量指定**。
* `retry` 某个job失败后的重试次数，最大为2。
* `resource_group` 有该标记的所有pipeline的job，只有执行完一个，下一个才会被执行。
* `script` 定义执行的命令，shell命令的方式。
* `stages` 重新定义pipeline的stage，默认stage为五个 `.pre`,`build`,`test`,`deploy`,`.post`。
* `tags` 指定哪个tag的gitlab-runner来运行pipeline。
* `timeout`  定义job任务的超时。
* `trigger` 在父子pipeline的时候使用，定义触发哪一个pipeline执行。
* `variables` 定义pipeline里面的变量。
* `when` 定义何时执行job。

## .gitlab-ci.yml 变量
1. 可以使用variable关键在在pipeline里面自定义变量。
2. 同时，gitlab-ci内置了许多变量: https://docs.gitlab.com/ee/ci/variables/predefined_variables.html

## .gitlab-ci.yml 编写
1. .gitlab-ci.yml文件采用yaml的格式，关键字有其特有的上下文等。
2. 编写可以使用页面上**CI/CD** -> **Editor**进行编写，这里会对pipeline语法的合法性进行校验。

## .gitlab-ci.yml 一个简单的go编写需求样例
1. 仓库存放的为go代码。
2. 要求对指定分支进行构建，其他分支不进行构建。
3. 构建得到的二进制文件可以下载。

```yaml
# 自定义变量
variables:
    BIN_PATH: bin/
    BIN_NAME: hello_world

# 全局定义使用哪个镜像，如果在stage里面没有单独定义image，则使用全局定义的镜像
image: golang:latest

# 自定义stage，总共三个 build  test export
stages:
    - build
    - test
    - export

# 全局定义cache， ${CI_COMMIT_REF_SLUG}为内置变量，作为key， 需要缓存的路径为$BIN_PATH
cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
        - $BIN_PATH

go:build:
    stage:
        build
    tags:
        - shared
    script:
        - go build -o ${BIN_PATH}${BIN_NAME} ./main.go
        - sleep 120
    # only里面定义哪个分支进行运行job，不可以使用变量
    only:
        - master
    # 当有多个pipeline运行的时候，当该阶段还未执行完毕的时候，其他定义了resource_group: go_build的pipeline都会处于 wait 状态。
    resource_group: go_build
    # 如果执行失败，或者stuck，或者超时，则进行重试，最多2次。
    retry:
        max: 2
        when:
        - runner_system_failure
        - stuck_or_timeout_failure


go:test:
    stage:
        test
    tags:
        - shared
    # 在job里面单独定义了image，则表示这个job使用alpine:latest来作为环境
    image: alpine:latest
    # 定义了执行脚本前的动作
    before_script:
        - chmod +x ${BIN_PATH}${BIN_NAME}
    script:
        - ./${BIN_PATH}${BIN_NAME} | grep -i "hello world"
    only:
        - master
    # 定义该job超时时间为20s
    timeout: 20s
    
go:export:
    stage:
        export
    tags:
        - shared
    script:
        ls ${BIN_PATH}${BIN_NAME}
    # 定义了制品的产出
    artifacts:
        # 制品名称
        name: ${BIN_PATH}
        # 将哪个路径进行制品归档
        paths:
            - bin
        # 制品保留一周
        expire_in: 1 week
    only:
        - master


```



最后的制品产出可以通过pipeline页面下载。

![](https://assets.iostat.io/image/artifacts-download.png)





refer:

> https://docs.gitlab.com/ee/ci/yaml/README.html
> https://docs.gitlab.com/ee/ci/variables/predefined_variables.html
