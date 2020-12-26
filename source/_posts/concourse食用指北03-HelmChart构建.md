---
title: concourse食用指北03-HelmChart构建
date: 2020-10-20 08:07:32
tags: [concourse, linux]
categories: application
---

## 需求
1. 根据仓库的helm chart，自动构建Chart，并且推送到Chart仓库

### 难点
1. 没有合适的resource，需要自己通过脚本实现。
2. 需要自己构建helm的镜像，用于chart的推送。


<!-- more -->


### 思路
1. 首先构建用于helm打包chart的基础镜像
2. 编写打包脚本
3. 配合脚本镜像chart打包，并上传至chart仓库

### helm基础镜像dockerfile部分内容
```shell
***
COPY helm /usr/local/bin/helm
RUN chmod +x /usr/local/bin/helm
RUN helm plugin install https://github.com/chartmuseum/helm-push
RUN helm repo add --username=xxx --password='yyy' harbor https:/hubname.com/chartrepo/yourreponame
```

**简单说明**
1. 将helm二进制文件添加到镜像中。
2. 安装helm-push插件，用于构建中push chart。
3. 添加helm源。

### chart打包推送脚本部分内容
```shell
***
chart_name=`cat $1/Chart.yaml | grep -E "^name"| awk '{print $NF}'`
chart_version=`cat $1/Chart.yaml | grep -E "^version"| awk '{print $NF}'`
helm package $1
repo_name=`helm repo list | grep -E "${Harbor_Url}" | awk '{print $1}'`
helm push ${package_info} ${repo_name}
***
```

**简单说明**
1. chart的名称以及version是从Chart.yaml文件中获取。
2. 打包后推送至当前helm镜像中的chart仓库中。


### 推送chart pipeline部分配置
```yaml
resources:
- name: harbor-script
  type: git
  icon: gitlab
  source:
    uri: ((repository.gitlab.url))/xxx/harbor-script.git
    branch: master
    username: ((repository.gitlab.username))
    password: ((repository.gitlab.password))

- name: chart-template
  type: git
  icon: gitlab
  source:
    uri: ((repository.gitlab.url))/helmchart/mysql.git
    username: ((repository.gitlab.username))
    password: ((repository.gitlab.password))
    branch: master
    
jobs:
- name: upload-chart
  plan:
    - get: harbor-script
      trigger: true
    - get: chart-template
      trigger: true
    - task: upload-helm
      config:
        platform: linux
        image_resource:
          type: docker-image
          source: 
            repository: ((repository.harbor.url))/helm-box
            username: ((repository.harbor.username))
            password: ((repository.harbor.password))
            tag: v1.3
        inputs:
        - name: harbor-script
        - name: chart-template
        run:
          user: root
          path: /bin/sh
          args: ["harbor-script/Upload-Chart.sh","mysql"]
```

**简单说明**

1. 将harbor-script以及chart-template两个resource获取到。
2. 将上述两个资源作为inputs提供给helm-box使用。
3. 在helm-box中执行Upload-Chart.sh脚本，传入待打包的路径名。

### 注意点
1. 上述功能，可以自定义编写成自定义的resource，这样传入的变量可以进行更好的控制。