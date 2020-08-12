---
title: 使用argo cd部署服务
date: 2020-08-03 17:39:22
tags: [kubernetes, argo-cd, kustomize, helm, concourse]
categories: application
---

# 部署流程图
![](https://image.kirakirazone.com/image/argo-cd-tech.png)



# 常用组件说明

* argo cd: 用于kubernetes application部署

* helm：用于生成helm template

* kustomize: 对生成的template进行细化定制

  



# 部署流程说明

1. gitlab从github中对所需部署的服务helm chart进行镜像克隆(mirror方式)，并作为submodule。
2. 用户以镜像仓库中的values.yaml文件作为模板，根据实际情况修改values.yaml，不更改源文件。
3. 用户编写kustomization.yaml，针对helm template生成的文件根据环境（dev,test,prod）不同细化配置。
4. 用户将变更推送到gitlab。
5. argo-cd触发同步，根据plugin中编写的方式，在kubernetes中进行部署。



# 案例：concourse部署
**通过部署concourse来具体说明该流程步骤。**

### 步骤一：镜像官方concourse chart镜像到本地gitlab

此操作在gitlab界面上，点点点就能完成，不再赘述。参考官方文档：

https://docs.gitlab.com/ee/user/project/repository/repository_mirroring.html

### 步骤二：创建一个concourse仓库，并且将之前创建的mirror仓库作为submodule加入到该仓库中
创建完毕后的目录结构如下所示
```shell
.
├── chart
├── kustomization.yaml
├── patches
├── resources
│   └── concourse-virtualservice.yaml
└── values.yaml

```
**目录结构说明：**
1. chart为从github上mirror到gitlab，并且作为submodule的路径，第一次拉取仓库需要执行`git submodule update --init`才能看到chat目录。
2. kustomization.yaml该文件为kustomize执行build命令的时候所需要，里面编写了需要替换或者更变的yaml配置内容。
3. patches路径用来细分patch文件，提高可读性，kustomization.yaml中按需引入。
4. resources路径是摆放需要合并的原文件，kustomization.yaml中按需引入。
5. values.yaml基于镜像仓库中的values.yaml再根据实际情况进行修改，比如修改了所需磁盘大小，外网访问地址信息等。

### 步骤三：以镜像中values.yaml为模板进行编写

**原镜像仓库中的values.yaml文件只做修改参考模板，不进行变更。**

1. 修改values.yaml中的一些值，比如登陆密码，pvc大小等。

### 步骤四：编写kustomization.yaml文件

1. 该文件主要对helm template -f values.yaml生成的yaml模板进行修改。

2. 样例： 

   1. kustomization.yaml

      ```yaml
      apiVersion: kustomize.config.k8s.io/v1beta1
      kind: Kustomization
      
      images:
      - name: concourse/concourse
        newName: registry.cn-shanghai.aliyuncs.com/hys-private/concourse
      - name: docker.io/bitnami/minideb
        newName: registry.cn-shanghai.aliyuncs.com/hys-private/minideb
      - name: docker.io/bitnami/postgresql
        newName: registry.cn-shanghai.aliyuncs.com/hys-private/postgresql
        
      resources:
        - all.yaml
        - resources/concourse-virtualservice.yaml
      ```

   2. resources/concourse-virtualservice.yaml

      ```shell
      apiVersion: networking.istio.io/v1alpha3
      kind: VirtualService
      metadata:
        name: concourse-virtualservice
        namespace: concourse-ci
      spec:
        gateways:
        - istio-system/ingressgateway
        hosts:
        - concourse-auto-prod.hys.com
        http:
        - route:
          - destination:
              host: concourse-ci-web.concourse-ci.svc.cluster.local
              port:
                number: 8080
      ```

### 步骤五：将修改完后的yaml文件提交到gitlab
该步骤省略

### 步骤六：argo-cd配置APP，并进行sync操作

该步骤待补充



### 碰到的一些问题

1. values.yaml中的namespace配置需要和argo-cd中app配置的namespace一致。



refer:

> https://kubernetes-sigs.github.io/kustomize/api-reference/

