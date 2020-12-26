---
title: k8s配置多集群接入
date: 2020-07-24 09:24:43
tags: [kubernetes]
categories: application
---

# 情景和思路
当需要接入多个kubernetes集群的情况，如果使用\-\-kubeconfig进行指定config file后执行kubectl命令会比较麻烦。可以使用`kubectl config use-context ${context_name}`命令进行切换context，从而实现一个config file文件能连接多个cluster的功能，当然一个时间段内是只能连接一个的。



# 配置文件路径

配置文件一般名称为`config`，放置路径为`$HOME/.kube/`目录下。

<!-- more -->

* **cluster**，定义cluster名称，认证信息等。

* **users**，定义users的名称，认证信息等。

* **contexts**，关联了cluster和user的信息。



# 在原有集群上追加额外集群信息

### 原有配置信息

```yaml
apiVersion: v1
clusters:
- cluster:
    server: https://server1.com
    certificate-authority-data: secret_info==
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: "340933575320448663"
  name: 340933575320448663-c1d785b5c421249d798362081b10830a6
current-context: 340933575320448663-c1d785b5c421249d798362081b10830a6
kind: Config
preferences: {}
users:
- name: "340933575320448663"
  user:
    client-certificate-data: secret_info==
    client-key-data: secret_info==
```



### 追加第二个集群的信息

1. 在`clusters`字段内定义了`name`字段，区分了两个不同的集群，一个是`k3s`，一个是`kubernetes`。
2. 在`users`字段内定义了两个user，一个是`340933575320448663`，一个是`default`。可以看出第一个user信息使用密钥方式登录；第二个使用用户名和密码登录
3. 通过`contexts`字段内可以看到将`cluster`和`name`进行了关联，`kubernetes`集群指定user采用`340933575320448663`上下文信息；`k3s`集群指定user使用`default`的上下文。
4. 还有一个独立的字段是`current-context`，表示当前配置文件采用哪个context，下面配置文件是使用的`k3s`，**那么此时当使用命令`kubectl`操作集群的时候，是去连接k3s这个集群**。

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: secret_info==
    server: https://server1.com
  name: k3s
- cluster:
    insecure-skip-tls-verify: true
    server: https://server2.com
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: "340933575320448663"
  name: kubernetes #切换使用的context_name
- context:
    cluster: k3s
    user: default
  name: k3s #切换使用的context_name
current-context: k3s
kind: Config
preferences: {}
users:
- name: "340933575320448663"
  user:
    client-certificate-data: secret_info==
    client-key-data: secret_info==
- name: default
  user:
    password: da25a8668cd6b469df139351c74c9eda
    username: admin
```



## 切换成另外一个集群

使用命令`kubectl config use-context ${context_name}`

比如当前我的context_name为k3s，要切换成配置中的kubernetes，则使用命令`kubectl config use-context kubernetes`

```shell
PS C:\Users\hysan\.kube> kubectl config use-context kubernetes
Switched to context "kubernetes".
```

此时使用kubectl命令，则连接到了kubernetes这个集群。



## 手动命令行进行配置三大件

查看refer官方文档。

refer:

> https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
