---
title: 做一个不专业的jenkins回滚
date: 2019-04-11 10:58:56
tags: [cicd,jenkins]
categories: application
---

## war包回滚思路

### 发布期间
1. 对正在提供服务的war包在*同目录*下，重命名为xxx.warbak
2. 并且对该war归档到指定目录

### 回滚期间
1. 将同目录下war的备份文件还原成xxx.war

## 用到的组件如下:
1. Customized Build Message Plugin（build后可以看到备注等自动传入的信息）
2. Build With Parameters  (build的时候选填参数)
3. Git Parameter Plug-In (选择分支，tag等)
4. Publish Over SSH  (通过ssh方式发包)

## 配置介绍
1. 每个publish over ssh的对象都存在两种情况，发布(deploy)和回滚(rollback)，所以需要对一个机器创建两个状态。
2. 根据build的时候传入的参数，deploy还是rollback，选择对应的行为。

## 配置截图
**图小新开一个浏览器页面看**

![](http://ww1.sinaimg.cn/large/9f0d15f3gy1g1yiam30k7j218g7wikiu.jpg)

## 部分代码:
1. 部署

```
[ -d "/opt/${tomcat_dir}/war" ] && echo 'back dir is exist' || mkdir -p /opt/${tomcat_dir}/war;
cp /opt/${tomcat_dir}/webapps/${tomcat_war}.war /opt/${tomcat_dir}/war/${tomcat_war}.war_`date +"%Y%m%d-%H%M"` || echo 'not exist war';
ps -ef | grep ${tomcat_dir} | grep -vP "cronolog|grep" | awk '{print $2}' | xargs -I {} kill {};
sleep 3;
rm -rf /opt/${tomcat_dir}/webapps/${tomcat_war};
/bin/mv /opt/${tomcat_dir}/webapps/${tomcat_war}.{war,warbak} || echo 'not exist war';
```

2. 回滚

```
ps -ef | grep ${tomcat_dir} | grep -vP "cronolog|grep" | awk '{print $2}' | xargs -I {} kill {};
sleep 3;
rm -rf /opt/${tomcat_dir}/webapps/${tomcat_war};
/bin/mv /opt/${tomcat_dir}/webapps/${tomcat_war}.{warbak,war} || echo 'not exist war';
/opt/${tomcat_dir}/bin/catalina.sh start;
```

## 存在问题
1. 由于采用的是maven项目，所以不论发布还是回滚都是会进行war包的build，其实在回滚的时候是不需要进行war包的build的。


refer:

> http://www.eryajf.net/1404.html