---
title: k8s拉取私有镜像
date: 2020-08-06 16:55:09
tags: [kubernetes]
categories: application
---

# 部署流程图
## 生产遇到的问题

k8s环境在一个阿里账号下，但阿里镜像仓库在另外的一个阿里账号下。

在k8s环境中部署服务的时候，发现镜像拉取失败，使用`kubectl describe pod xxx`在event字段发现如下报错：

```shell
Events:
  Type     Reason     Age                From                Message
  ----     ------     ----               ----                -------
  Normal   Scheduled  <unknown>          default-scheduler   Successfully assigned default/nginx to k3s-node2
  Warning  Failed     59s                kubelet, k3s-node2  Error: ErrImagePull
  Warning  Failed     59s                kubelet, k3s-node2  Failed to pull image "registry.cn-shanghai.aliyuncs.com/huangyisan/nginx:latest": rpc error: code = Unknown desc = failed to pull and unpack image "registry.cn-shanghai.aliyuncs.com/huangyisan/nginx:latest": failed to resolve reference "registry.cn-shanghai.aliyuncs.com/huangyisan/nginx:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
  Warning  Failed     59s                kubelet, k3s-node2  Error: ImagePullBackOff


```

报错信息表明了镜像不存在，或者需要认证后才能拉取。

然后上阿里云控制台检查了下，发现仓库是私有类型，当时改成了公有类型，的确可以拉取镜像了。

**但是如果镜像是根据公司业务定制化，包含了公司敏感信息，那么此时就不适合作为公有类型了**。



## 两种方法解决拉取私有镜像的问题

### 方法一：通过Docker credentials创建K8S Secret资源

1. 使用docker login ${registry-addr}。

2. 输入用户名和密码。

3. 认证通过后docker会把认证信息以明文的方式默认存放到`/root/.docker/config.json`文件内。**该文件存放了所有认证通过的镜像仓库，并且使用base64编码了用户名和密码，所以如果要查看用户名和密码，只需要base64 decode即可。**

4. 使用一下命令就可以在k8s的secret资源中添加一条记录了。

   ```shell
   kubectl create secret generic ${secret-name} \
       --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
       --type=kubernetes.io/dockerconfigjson
   ```



## 方法二：使用命令行的方式添加K8S Secret资源

1. 使用如下命令就可以在k8s的secret资源中添加一条记录了。

   ```shell
   kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
   ```

   其中your-email可以任意填写



## 验证镜像拉取

1. 修改yaml文件，添加imagePullSecrets字段，使用name: ${secret-name}来指定使用哪个secret资源。

   ```shell
   apiVersion: v1
   kind: Pod
   metadata:
     name: nginx
     labels:
       env: test
   spec:
     containers:
     - name: nginx
       image: registry.cn-shanghai.aliyuncs.com/huangyisan/nginx:latest
       imagePullPolicy: Always
     imagePullSecrets:
     - name: ali-hys
   ```

2. 删除pod后重新部署，查看event字段发现已经可以正常拉取了。

   ```shell
   Events:
     Type    Reason     Age        From                Message
     ----    ------     ----       ----                -------
     Normal  Scheduled  <unknown>  default-scheduler   Successfully assigned default/nginx to k3s-node2
     Normal  Pulling    6s         kubelet, k3s-node2  Pulling image "registry.cn-shanghai.aliyuncs.com/huangyisan/nginx:latest"
     Normal  Pulled     6s         kubelet, k3s-node2  Successfully pulled image "registry.cn-shanghai.aliyuncs.com/huangyisan/nginx:latest"
     Normal  Created    6s         kubelet, k3s-node2  Created container nginx
     Normal  Started    5s         kubelet, k3s-node2  Started container nginx
   
   ```



## 查看secret资源

1. kubectl get secret -n \<namespace\>

   ```shel
   [root@test ~/k8s] # kubectl get secret
   NAME                                 TYPE                                  DATA   AGE
   default-token-jktlx                  kubernetes.io/service-account-token   3      48d
   my-release-ingress-nginx-admission   Opaque                                3      26h
   ali-hys                              kubernetes.io/dockerconfigjson        1      55m
   ali-json                             kubernetes.io/dockerconfigjson        1      31m
   You have new mail in /var/spool/mail/root
   
   ```

2. **通过get指定的secret名称，-o yaml导出，其实也可以看到base64编码后的信息，只要decode就能看到明文**



refer:

> https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

