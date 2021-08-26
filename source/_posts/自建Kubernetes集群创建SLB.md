## 需求

​    当前环境没有使用阿里云ack托管kubernetes服务，而是采用了购买ECS，自建集群的方式。ingress svc需要使用LoadBalancer的Type类型来创建阿里云slb服务。



## 解决方案

阿里云已经给出了解决方法，首先是创建阿里云CCM资源，然后指定svc Type类型，就会自动创建slb服务了。



> 阿里云官方文档目前暂未提供部署CCM的方法，所以自己根据github的文档对其进行了部署，并且验证了可用性，以下为部署方式，也包含了踩的几个坑。



## 前置准备

* 在阿里云环境自建的ecs服务器的kubernetes集群。
* AK,SK需要对部分资源进行授权。具体哪些下面会提到。



**因为我的集群已经在运行，使用的kubeadm部署，而不是从一开始初始化阶段为CCM做准备。**



## 部署过程

1. 依次获取所有的node节点的REGION和INSTANCE信息。**注意需要每个node节点都去获取。**

   ```shell
   # 通过命令获取到region-id和instance-id信息
   META_EP=http://100.100.100.200/latest/meta-data
   $ echo `curl -s $META_EP/region-id`.`curl -s $META_EP/instance-id`
   ```

   

2. **对每个节点进行patch**，将region-id和instance-id组合作为provide-id

   ```shell
   kubectl patch node ${NODE_NAME} -p "{\"spec\":{\"providerID\": ${region-id}.${instance-id} }}"
   ```

   

3. 创建一个RAM用户(我个人推荐不在主账户下创建，而是用子账户来管理)，生成AKSK，该AKSK需要有访问部分资源的访问权限，这些权限至少包含[master.policy](https://github.com/kubernetes/cloud-provider-alibaba-cloud/blob/master/docs/examples/master.policy)里面的权限，**当时我就是想当然的以为只需要slb权限即可，导致一直无法创建。**所以我给的权限是AliyunECSFullAccess。

4. 将ak sk进行base64编码，并存储到configmap资源中。

   ```shell
   # base64 AccessKey & AccessKeySecret
   $ echo -n "$AccessKeyID" |base64
   $ echo -n "$AcceessKeySecret"|base64
   
   $ cat <<EOF >cloud-config.yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: cloud-config
     namespace: kube-system
   data:
     cloud-config.conf: |-
       {
           "Global": {
               "accessKeyID": "$your-AccessKeyID-base64",
               "accessKeySecret": "$your-AccessKeySecret-base64"
           }
       }
   EOF
   
   $ kubectl create -f cloud-config.yaml
   ```

5. 在/etc/kubernetes路径下创建cloud-controller-manager.conf的文件，并用ca.crt  64编码替换$CA_DATA内容，修改server地址为自身的api-server地址。

   ```shell
   # 生成base64编码
   cat /etc/kubernetes/pki/ca.crt|base64 -w 0
   
   # 生成cloud-controller-manager.conf文件
   kind: Config
   contexts:
   - context:
       cluster: kubernetes
       user: system:cloud-controller-manager
     name: system:cloud-controller-manager@kubernetes
   current-context: system:cloud-controller-manager@kubernetes
   users:
   - name: system:cloud-controller-manager
     user:
       tokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
   apiVersion: v1
   clusters:
   - cluster:
       # 注意替换$CA_DATA
       certificate-authority-data: $CA_DATA
       # 这里填写集群api-server的地址
       server: https://192.168.1.76:6443
     name: kubernetes
   ```

   

6. 下载[cloud-controller-manager.yml](https://raw.githubusercontent.com/kubernetes/cloud-provider-alibaba-cloud/master/docs/examples/cloud-controller-manager.yml)文件，并替换--cluster-cidr地址。

   ```shell
   # 获取cluster-cidr地址
   kubectl cluster-info dump | grep cluster-cidr
   ```

   

7. 对第六步的cloud-controller-manager.yml文件apply操作，然后观察kube-system的ns下是否生成了cloud-controller-manager-xxxx的pod，并且正常运行。

   ```shell
   kubectl get pod -n kube-system
   ```

   

8. 进行创建LoadBalancer的测试，可以使用官方说明的最后几步，因为我这边用了nginx ingress, 所以直接修改了nginx ingress svc的type为LoadBalancer，保存后就自动创建SLB，可以通过查看cloud-controller-manager-xxxx的log看到具体信息。**这里我一开始出现了Your account does not have enough balance的报错导致创建失败，那会查看余额是33块多点，后来我充值了100元，就成功创建了。**在命令行可以通过`kubect get svc -n ingress-nginx`看到，svc的外网地址。

9. 如果修改了svc的Type，从Loadbalancer改成其他的，会自动删除slb。

ref:

> https://github.com/kubernetes/cloud-provider-alibaba-cloud
