---
title: Helm的简单使用
date: 2020-06-21 23:58:21
tags: [k8s, helm]
categories: application
---

# HELM基本介绍
helm是一个可以让k8s上的应用服务进行简便安装，方便管理的工具。可以理解对yum/apt等包管理工具，只不过他是k8s特有的。

目前helm有v2以及v3版本。v2版本需要客户端和服务端相互配合，服务端成为tiller，而v3的版本则不需要服务端的支持了。对于helm的命令，v2和v3也有许些区别。

为什么要有helm? 通常我们一个k8s应用服务有pods, depolyment, services，ingress等等若干组件来组成，且部分组件还有相互调用的关系，你可以需要编写很多个yaml文件来处理其中之间的关系。你自己对这些文件了如指掌，但如果进行交付给他人维护，或者要做ci/cd的话，可能就不是很方便了。使用helm，编写chart，或者使用互联网上已经存在的现存chart，通过命令，非常便捷的部署和管理应用服务。

**本篇使用的是v3版本。**



# HELM的三个概念

* **Chart**，chart类似yum list 所看到的包。安装后则在k8s上进行运行。

* **Repository**，则是helm的源，和yum源类似，可以配置多个，但刚安装完毕的helm没有默认源，需要手工配置。

* **Release**，则是安装了chart后，在k8s上运行的服务，称之为release。简单理解就是，某个应用还未部署在k8s上，称之为chart，部署后称之为release。



# HELM的使用

### HELM的安装

常用的三个平台(linux, mac, win)都有对应的二进制包，可以去github下载。[github地址](https://github.com/helm/helm)



### 配置HELM源

跟yum类似，但helm一开始是不存在默认的源，需要手工配置。

配置命令为`helm repo add 源名称 源地址`。国内可以添加微软的源，谷歌的基本上被墙。

```powershell
PS C:\Users\hysan\Desktop> helm repo add google https://kubernetes-charts.storage.googleapis.com/
"google" has been added to your repositories
```



可以使用`helm repo list`查看当前存在的helm repo。 添加完后对repo更新`helm repo update`

```powershell
PS C:\Users\hysan\Desktop> helm repo list
NAME            URL
concourse       https://concourse-charts.storage.googleapis.com/
stable          http://mirror.azure.cn/kubernetes/charts/
google          https://kubernetes-charts.storage.googleapis.com/
```



查看指定repo内的包(称之为chart), 被列出来的都是源里面的chart，使用命令`helm search repo repo名称`

```powershell
PS C:\Users\hysan\Desktop> helm search repo google
NAME                                    CHART VERSION   APP VERSION             DESCRIPTION

google/acs-engine-autoscaler            2.2.2           2.1.1                   DEPRECATED Scales worker nodes within agent pools
google/aerospike                        0.3.2           v4.5.0.5                A Helm chart for Aerospike in Kubernetes

google/airflow                          7.1.5           1.10.10                 Airflow is a platform to programmatically autho...
google/ambassador                       5.3.2           0.86.1                  DEPRECATED A Helm chart for Datawire Ambassador
...
..
.
```



### 查看指定的chart

使用`helm search repo chart名称`便会列出所有repo中符合的chart。

```
PS C:\Users\hysan\Desktop> helm search  repo concourse
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
concourse/concourse     11.2.1          6.3.0           Concourse is a simple and scalable CI system.
google/concourse        8.3.7           5.6.0           DEPRECATED Concourse is a simple and scalable C...
stable/concourse        8.3.7           5.6.0           DEPRECATED Concourse is a simple and scalable C...
```



查看一个具体的chart信息，使用`helm show chart chat名称`

比如我查看google/mysql这个chart

```powershell
PS C:\Users\hysan\Desktop> helm show chart google/mysql
apiVersion: v1
appVersion: 5.7.30
description: Fast, reliable, scalable, and easy to use open-source relational database
  system.
home: https://www.mysql.com/
icon: https://www.mysql.com/common/logos/logo-mysql-170x115.png
...
..
.
```



查看**更加具体**的chart信息，使用`helm show all chart名称`

```powershell
PS C:\Users\hysan\Desktop> helm show  all google/mysql
apiVersion: v1
appVersion: 5.7.30
description: Fast, reliable, scalable, and easy to use open-source relational database
  system.
home: https://www.mysql.com/
icon: https://www.mysql.com/common/logos/logo-mysql-170x115.png
...
..
.
```



查看**全部可用版本**，使用`-l`或者`--versions`

例如查看google/mariadb 各种版本。

```shell
PS C:\Users\hysan\Desktop> helm search repo google/mariadb --versions
NAME            CHART VERSION   APP VERSION             DESCRIPTION
google/mariadb  7.3.14          10.3.22                 DEPRECATED Fast, reliable, scalable, and easy t...
google/mariadb  7.3.13          10.3.22                 DEPRECATED Fast, reliable, scalable, and easy t...
google/mariadb  7.3.12          10.3.22                 Fast, reliable, scalable, and easy to use open-...
google/mariadb  7.3.11          10.3.22                 Fast, reliable, scalable, and easy to use open-...
google/mariadb  7.3.10          10.3.22                 Fast, reliable, scalable, and easy to use open-...
google/mariadb  7.3.9           10.3.22                 Fast, reliable, scalable, and easy to use open-...
...
..
.
```





## 安装/删除一个Chart

安装一个chart，使用`helm install 在k8s上定义的release名 chart名`

这边要注意的是，如果k8s在远程，则需要使用--kubeconfig k8s文件来使用。

**如果要指定某个版本，则可以使用`--verison vx.y`方式，例如`helm install prometheus --version v6.7.4 `**

比如远程安装一个concourse的服务。*在上面选择concourse/concourse这个chart安装*

```shell
helm install --kubeconfig C:\Users\hysan\Desktop\k3s.yaml my-concourse concourse/concourse
```



如果不想自己取名，则可以使用`--generate-name`

```shell
helm install --kubeconfig C:\Users\hysan\Desktop\k3s.yaml  concourse/concourse --generate-name`
```



使用`kubectl get all`可以查看k8s是否安装了concourse。

```shell
uangyisan@k3s-master:~$ sudo ./k3s kubectl get all
NAME                                    READY   STATUS    RESTARTS   AGE
pod/my-nginx-9b596c8c4-62gm2            1/1     Running   1          22h
pod/my-concourse-worker-1               1/1     Running   0          117s
pod/my-concourse-worker-0               1/1     Running   0          117s
pod/my-concourse-postgresql-0           1/1     Running   0          117s
pod/my-concourse-web-7bb67d8c8c-v26lm   1/1     Running   0          117s

NAME                                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/kubernetes                         ClusterIP   10.43.0.1       <none>        443/TCP          3d4h
service/web-proxy                          NodePort    10.43.166.153   <none>        8080:30080/TCP   2d5h
service/my-concourse-postgresql-headless   ClusterIP   None            <none>        5432/TCP         118s
service/my-concourse-worker                ClusterIP   None            <none>        <none>           118s
service/my-concourse-web                   ClusterIP   10.43.184.42    <none>        8080/TCP         118s
service/my-concourse-web-worker-gateway    ClusterIP   10.43.96.157    <none>        2222/TCP         118s
service/my-concourse-postgresql            ClusterIP   10.43.215.201   <none>        5432/TCP         118s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-nginx           1/1     1            1           22h
deployment.apps/my-concourse-web   1/1     1            1           118s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/my-nginx-9b596c8c4            1         1         1       22h
replicaset.apps/my-concourse-web-7bb67d8c8c   1         1         1       118s

NAME                                       READY   AGE
statefulset.apps/my-concourse-worker       2/2     118s
statefulset.apps/my-concourse-postgresql   1/1     118s

```



使用`helm list`可以查看当前k8s部署了的chart，也就是列出release。

```shell
PS C:\Users\hysan\Desktop> helm list --kubeconfig C:\Users\hysan\Desktop\k3s.yaml
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART          APP VERSION
my-concourse    default         1               2020-06-21 22:15:46.0507691 +0800 CST   deployed        concourse-11.2.6.3.0
```



删除命令也很简单，install修改为uninstall，指定release名称即可。`helm uninstall release名称`

```shell
PS C:\Users\hysan\Desktop> helm uninstall --kubeconfig C:\Users\hysan\Desktop\k3s.yaml my-concourse
manifest-0

release "my-concourse" uninstalled
```



### 自定义变量安装

1. 如果编写过自己的chart，则能知道其其实是由一个个yaml，或其他文件组成。
2. 自己编写的chart，可以将value抽取出来，放到Values.yaml文件中。那么在安装的时候可以改写变量，或者指定某个变量的值进行安装。



#### 打印出指定chart的value内容

其实打印的就是values.yaml文件的内容，使用命令`helm show values chart名称`

比如查看concourse/concourse这个chart的values

```shell
PS C:\Users\hysan\Desktop> helm  --kubeconfig C:\Users\hysan\Desktop\k3s.yaml  show values concourse/concourse
## Default values for Concourse Helm Chart.
## This is a YAML-formatted file.
## Declare variables to be passed into your templates.

## Provide a name in place of `concourse` for `app:` labels
##
nameOverride:

## Provide a name to substitute for the full names of resources
##
fullnameOverride:

## Concourse image to use in both Web and Worker containers.
##
image: concourse/concourse
...
..
.
```



**我们可以把这个文件定向到一个yaml文件，然后修改里面需要修改的值，在使用-f指定该修改后的yaml文件进行安装。**

进行重定向到一个文件中

```shell
PS C:\Users\hysan\Desktop> helm  --kubeconfig C:\Users\hysan\Desktop\k3s.yaml  show values concourse/concourse > C:\Users\hysan\Desktop\concourse.yml
```



#### 覆盖变量进行安装

使用-f或者--values指定该concourse.yaml进行安装

```shell
helm --kubeconfig .\k3s.yaml install -f .\concourse.yml concourse concourse/concourse
```



**如果只需要修改一个值，嫌导出麻烦，则可以使用--set name=value的方式修改并安装。如果同时存在--set方式和-f指定yaml文件的方式，--set的修改内容会覆盖-f指定的yaml文件内容**



### HELM进行更新和回退

当需要对HELM部署的应用进行更新的时候，先修改yaml文件，然后使用upgrade进行更新。`helm upgrade -f .\concourse.yml  release名称 chart名称`

```shell
PS C:\Users\hysan\Desktop> helm --kubeconfig .\k3s.yaml upgrade -f .\concourse.yml  concourse concourse/concourse
Release "concourse" has been upgraded. Happy Helming!
NAME: concourse
LAST DEPLOYED: Sun Jun 21 22:48:05 2020
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
* Concourse can be accessed:
```



upgrade操作后，可以使用`helm get values release名称`命令查看更新的value是否更新。



通过`helm list`命令可以看到concourse此时的`REVISION`更新为**2**了。

```shell
PS C:\Users\hysan\Desktop> helm --kubeconfig .\k3s.yaml list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART          APP VERSION
concourse       default         2               2020-06-21 22:48:05.9812653 +0800 CST   deployed        concourse-11.2.6.3.0
```



如果要回退到**REVISION 1 时候的状态**，则可以使用rollback命令，`helm rollback release名称 回退的版本`

```shell
PS C:\Users\hysan\Desktop> helm --kubeconfig .\k3s.yaml rollback concourse 1
Rollback was a success! Happy Helming!
```



**这边回滚了，但千万不要认为REVISION变成了1，当前只是回到了曾经1的状态，但REVISION一直都是递增的，也就是之前的2+1=3。**

```shell
PS C:\Users\hysan\Desktop> helm --kubeconfig .\k3s.yaml list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART          APP VERSION
concourse       default         3               2020-06-21 22:54:03.8030572 +0800 CST   deployed        concourse-11.2.6.3.0
```



# HELM其他一些命令

* [helm get manifest release名称](https://helm.sh/docs/helm/helm_get_manifest/) 用来获取release的mainfest文件
* [helm pull chart名称](https://helm.sh/docs/helm/helm_pull/) 下载指定chart，查看其编写文件
* 很多命令可以配合`--flag`内容来做更多的展现，[更多参考](https://helm.sh/docs/helm/)





refer:

> https://helm.sh/docs/

Helm的一些缺点

> https://winderresearch.com/7-reasons-why-you-shouldnt-use-helm-in-production/#value-proposition