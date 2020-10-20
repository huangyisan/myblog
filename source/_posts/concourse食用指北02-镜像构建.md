---
title: concourse食用指北02-镜像构建
date: 2020-10-19 17:39:22
tags: [concourse, linux]
---

## 需求
1. 根据仓库的dockerfile，自动构建镜像，并且推送到镜像仓库

### 知识点
1. 镜像构建可以使用[docker-image-resource](https://github.com/concourse/docker-image-resource)

### 思路
1. 拉取dockerfile代码仓库
2. 构建镜像
3. 推送到镜像仓库

### 第一版pipeline部分配置
```yaml
resources:
- name: git-repo
  type: git
  icon: gitlab
  source:
    uri: ((repository.gitlab.url))/test.git
    branch: master
    username: ((repository.gitlab.username))
    password: ((repository.gitlab.password))
    tag_filter: "v*"
    
- name: test-image
  type: docker-image
  icon: docker
  source:
    repository: ((repository.harbor.url))/test-image
    username: ((repository.harbor.username))
    password: ((repository.harbor.password))
    
jobs:
- name: publish
  serial: true
  plan:
  - do:
    - get: git-repo
      trigger: true
    - put: test-image
      params:
        build: git-repo
        tag_file: git-repo/.git/ref
```

**简单说明**

1. 定义两个resource，一个为git类型，用于git仓库的操作；另外一个为docker-image类型，用于镜像构建以及镜像仓库的操作。
2. jobs的put阶段，表示对dockerfile的构建，以及镜像仓库的推送。
3. tag_file用于给定镜像的tag，这边使用.git/ref表示，git仓库用的哪个tag，则将该tag添加给镜像。

### SemVer捕获
1. 让镜像tag使用Semantic Versioning
2. docker的镜像tag采用[SemVer](https://semver.org/)的方式，而代码仓库的tag未必完全遵循了SemVer。

### 解决方法
1. 开发协商代码仓库的tag使用规范。
2. concourse编写task，用正则的方式捕获tag中SemVer部分。
3. 镜像构建的时候采用上步骤中捕获到的SemVer。

### 第二版pipeline部分配置
```yaml
jobs:
- name: publish
***
  plan:
  - do:
    ***
    - task: get-servmer
      file: concourse-brain/tasks/get-sermver.yaml
    - put: test-image
      params:
        build: git-repo
        tag_file: git-repo-tag/tag
    ***
```
`git-repo-tag/tag`该文件记录了task执行后捕获到的SemVer


**get-sermver.yaml 部分task配置**
```yaml
---
platform: linux
***
run:
  path: /bin/sh
  args:
  - -c
  - |
    cd git-repo
    last_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
    echo ${last_tag} > last_tag
    res=$(perl -nle'print $& while m{REGEX}g' last_tag)
    if [ ! -n "$res" ] ;then echo ${last_tag} > ../outputs-file/tag; else echo ${res} > ../git-repo-tag/tag ;fi
```
主要是将tag进行正则匹配，写入git-repo-tag/tag，供docker-image resource读取。

### 注意点
1. 一般alpine，busybox等镜像没有pcre库，也就是grep无法支持perl模式-P，导致一些正则无法正常匹配。
2. 安装pcre产生的镜像空间远大于安装perl，可以直接采用perl的方式来解决上述问题。具体语法为`perl -nle'print $& while m{REGEX}g' file`


