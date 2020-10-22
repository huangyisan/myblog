---
title: concourse食用指北01-自动创建pipelines
date: 2020-10-19 16:15:56
tags: [concourse, linux]
categories: application
---

之前没有接触过使用concourse做ci/cd工具，这次进行了尝试，该文档主要是记录了对使用过程中的一些改进。

我这边会记录对每个需求的设计和改进。

## 需求
1. 只需要提交代码，能让concourse自动创建pipelines。

### 知识点
1. concourse有别于jenkins，其UI主要是用来查看pipelines/jobs的状态，在页面不允许创建，修改或者删除pipelines。
2. 创建pipelines通过cli的方式可以使用`set-pipeline`命令来实现，具体语句为`fly -t main set-pipeline -p ${pipeline_name} -c ${config_file}`。
3. pipeline yaml中可以使用`set_pipeline`关键字来生成pipeline。

### 初版目录结构

```shell
.
├── pipelines
├── README.md
└── set-pipelines.yml

```
**结构说明**
1. pipelines目录用于存放子pipelines。
2. set-pipelines.yml文件中定义了待创建的pipelines，例如如下部分，表明创建一个名称为test-pipeline，该pipelines的生成是根据set-pipeline/pipelines/test-pipeline.yml配置文件。

```yaml
  - name: set-pipelines
    plan:
      - get: set-pipeline
        trigger: true # 触发式更新
      - set_pipeline: test-pipeline
        file: set-pipeline/pipelines/test-pipeline.yml
***
```

### 初版存在的问题
1. 虽然子pipeline的更新无需手动了，但set-pipelines.yml文件的更新还是需要手工执行fly -t main set-pipeline的命令。

### 解决方法
1. 引入一个总控的pipeline，去控制set-pipelines.yml
2. 当pipeline代码仓库更新的时候，self-update.yml去触发更新set-pipelines.yml，而self-update.yml定义好后一般无需对其进行修改。

### 第二版目录结构
```yaml
.
├── pipelines
├── README.md
├── self-update.yml
└── set-pipelines.yml

```
**结构说明**
1. self-update,yml该文件用于控制set-pipelines.yml，其对set-pipelines,yml的文件控制也是采用了set-pipeline

### 第二版存在的问题
1. 如果添加子pipeline，需要两步走，第一步在pipelines文件夹内放入子pipeline定义的yaml文件，第二步，修改set-pipelines.yml文件，新增子pipeline在set-pipeline上下文的定义。

### 解决方法
1. 采用动态的方式生成set-pipelines.yml文件，也就是在concouse运行的时候，根据目录结构自动生成set-pipelines.yml，从而满足需求。

### 第三版目录结构

```yaml
├── pipeline_render.py
├── pipelines
├── README.md
├── self-update.yml
├── set-pipelines.jinja
```

**结构说明**
1. 新增set-pipelines.jinja以及pipeline_render.py两个文件，pipeline_render.py读取pipelines目录下的文件，根据set-pipelines.jinja模板动态生成set-pipelines.yml，提供给concouse使用。

### 实现知识点
1. 配合python镜像，对pipelines仓库下pipelines目录进行set-pipelines.yml文件渲染。
2. 定义outputs，将渲染好的新内容定向到该outputs中。
3. 根据outputs的路径，进行set-pipelines。

### 注意点
1. self-update.yml的job执行必须在set-pipelines.yml的job之前执行完成，所以需要给set-pipelines.yml一个delay的延时，如果set-pipelines.yml的job先于self-update.yml执行完成，则子pipelines无法会更新。

