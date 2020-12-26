---
title: concourse食用指北04-编写一个自定义resource
date: 2020-10-20 11:27:32
tags: [concourse, linux]
categories: application
---

## 需求
1. 编写一个自定义微信告警resource

### 知识点
1. 一个resource的执行有三个阶段组成，`check`，`in`，`out`。
2. 任意一个阶段，传入的字段都为固定，且都有其固定的标准输出格式。
3. check对应check，in阶段对应yaml中的`get`，out阶段对应yaml中的`put`。
4. 如果要在concourse ui打印输出，则需要将标准输出重定向到标准错误输出。
5. in阶段和out阶段只是逻辑上对你的resource代码进行区别，并不是强制某些代码必须写在in阶段。而check阶段的代码则是强制。
6. 三个阶段执行顺序为check阶段，in阶段，out阶段。
7. 编写的dockerfile需要将check in out作为可执行文件放入/opt/resource下面。

<!-- more -->

### check阶段
1. check阶段为资源执行的第一个阶段，主要用于检查资源的最新版本。
2. 传入两个字段，一个为source，一个为version， 例如`{“source”: {“url”: “git-url”,  “user”: “abc”, “password”: “xyz”}, “version”: "777"}`
3. 标准输出则为数组形式的kv键值对[{"key1": "value", "key2":" value2"}]

### in阶段
1. in阶段为check之后的第二个阶段。
2. 在out阶段执行完毕后，也会再次执行in阶段，用于预期目标的验证。
3. in阶段传入三个字段，source，version，params，例如`{“source”: {“url”: “git-url”,  “user”: “abc”, “password”: “xyz”}, “version”: "777", params:{"tag":123}}`
4. 其标准输出为以必须存在以"version"为key的多维字典，例如`{"version": {"key": version, "metadata": [{ "name": "commit", "value": "61cebf" },{ "name": "author", "value": "Hulk Hogan" }]}}`

### out阶段
1. out阶段为最后一个阶段。
2. out阶段传入三个字段source，params，例如`{"params": {"branch":"develop","repo": "some-repo"},"source": {"uri": "git@...","private_key": "..."}}`
3. 其标准输出为必须存在以"version"为key的多维字典{"version": { "ref": "61cebf" },"metadata":[{ "name": "commit", "value": "61cebf" },{ "name": "author", "value": "Mick Foley" }]}

## 尝试编写一个用于微信告警的resource type

### 思路
1. 该resource不属于像git，docker-image等需要检查版本的resource，所以check阶段可以省略。但check脚本还是需要。
2. in阶段，因为只是告警，所以在自身resource中不需要尝试拉取任何资源。
3. out阶段，此阶段用于告警通知，需要规划变量进行传入。变量包含但不限于微信机器人token，告警内容，告警级别等。

### check阶段部分代码
```python
def _check():
    timestamp = get_timestamp()
    return [{"version": timestamp, "stage": "check"}]
if __name__ == "__main__":
    print(json.dumps(_check()))
```

**简单说明**
1. 这边没有直接打印空，而是采取打印时间戳，这样就能在concourse ui页面看到是否正常执行了check。

### in阶段部分代码
```python
def _check():
    timestamp = get_timestamp()
    return {"version": {"version": timestamp, "stage": "in"}}
if __name__ == "__main__":
    print(json.dumps(_check()))
```
**简单说明**
1. 雷同check部分代码。

### out部分阶段代码
```python
def get_env():
    BUILD_PIPELINE_NAME = os.getenv('BUILD_PIPELINE_NAME')
    BUILD_PIPELINE_ID = os.getenv('BUILD_PIPELINE_ID')
    BUILD_NAME = os.getenv('BUILD_NAME')
    BUILD_TEAM_NAME = os.getenv('BUILD_TEAM_NAME')
    BUILD_JOB_NAME = os.getenv('BUILD_JOB_NAME')
    BUILD_ID = os.getenv('BUILD_ID')
    BUILD_TEAM_ID = os.getenv('BUILD_TEAM_ID')
    BUILD_JOB_ID = os.getenv('BUILD_JOB_ID')
    ATC_EXTERNAL_URL = os.getenv('ATC_EXTERNAL_URL')
    URL = '{ATC_EXTERNAL_URL}/teams/{BUILD_TEAM_NAME}/pipelines/{BUILD_PIPELINE_NAME}/jobs/{BUILD_JOB_NAME}/builds/{BUILD_NAME}'.format(
        ATC_EXTERNAL_URL=ATC_EXTERNAL_URL,
        BUILD_TEAM_NAME=BUILD_TEAM_NAME,
        BUILD_PIPELINE_NAME=BUILD_PIPELINE_NAME,
        BUILD_JOB_NAME=BUILD_JOB_NAME,
        BUILD_NAME=BUILD_NAME)
    env_dict = {
        'BUILD_PIPELINE_NAME': BUILD_PIPELINE_NAME,
        'BUILD_PIPELINE_ID': BUILD_PIPELINE_ID,
        'BUILD_NAME': BUILD_NAME,
        'BUILD_TEAM_NAME': BUILD_TEAM_NAME,
        'BUILD_JOB_NAME': BUILD_JOB_NAME,
        'BUILD_ID': BUILD_ID,
        'BUILD_TEAM_ID': BUILD_TEAM_ID,
        'BUILD_JOB_ID': BUILD_JOB_ID,
        'ATC_EXTERNAL_URL': ATC_EXTERNAL_URL,
        'URL': URL
    }
    return env_dict
    
    def payload_data(payload):
    # source = payload["source"]
    source = payload["params"]
    url = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send" if not source.get("url") else source.get("url")
    secret = source["secret"]
    msgtype = "markdown" if not source.get("msgtype") else source.get("msgtype")
    # success, failed, abort
    level = "success" if not source.get("level") else source.get("level")
    content = "No content" if not source.get("content") else source.get("content")
    payload_dict = {"url": url, "secret": secret, "msgtype": msgtype, "level": level,
                    "content": content}
    return payload_dict

def _out(stream):
    payload = get_args(stream)
    payload_dict = payload_data(payload)

    url, secret, msgtype, level, content = payload_dict.values()

    data = message(msgtype, level, content)
    post_message(url, secret, data)
    timestamp = get_timestamp()
    return {"version": {"version": timestamp}}
```

**简单说明**
1. get_env函数用于获取concouse在up一个容器的时候传入的metadata，**其metadata信息是作为环境变量存储在镜像里面的**。
2. payload_data函数用于获取yaml配置中put的参数，通过从params中获取。
3. \_out方法执行了向微信接口进行post数据，并最终返回标准输出给main函数进行打印。

## dockerfile的编写

### 要点
1. 需要将check in out三个文件放入/opt/resource下面。
2. 给check in out文件可执行权限。

### dockerfile样例
```shell
FROM alpine
MAINTAINER anonymousyisan@gmail.com

RUN apk add --update --no-cache python3  py-pip && ln -sf python3 /usr/bin/python
RUN pip install requests

COPY assets/check.py /opt/resource/check
COPY assets/in.py /opt/resource/in
COPY assets/out.py /opt/resource/out

RUN chmod +x /opt/resource/*

```

## yaml配置自定义resource

### yaml部分配置

#### 定义resource type以及定义resource
```yaml
resource_types:
- name: wx-alert-resource
  type: docker-image
  source:
    repository: dockerhuangyisan/wechat-notification-resource
    tag: latest

resources:
- name: wx-alert
  type: wx-alert-resource
```

#### hook阶段执行put
```yaml
jobs:
- name: publish
  plan:
      ****
      on_success:
        put: wx-alert
        params:
          secret: ((wx.secret))
          msgtype: markdown
          level: success
          content: Job Success!
```

### 微信端告警样例
![wechat_message_example](https://image.kirakirazone.com/image/wechat_message.png)

## 调试技巧
1. 如果想在resource中进行调试，不要直接在标准输出中打印，因为concouse会捕获标准输出进行验证是否为合法VersionResult，所以处理办法就是将标准输出定向到标准错误输出中，python可以使用print("strings", file=sys.stderr),  shell可以exec 3>&1;exec 1>&2。


参考
-----
1. wechat notification resource源码地址:https://github.com/huangyisan/wechat_notification_resource
2. 官方介绍: https://concourse-ci.org/implementing-resource-types.html
3. https://medium.com/devops-dudes/writing-a-custom-concourse-resource-overview-1ed6d2983e39



