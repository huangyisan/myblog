---
title: 编写自定义 django-admin 命令
date: 2019-11-07 15:58:56
tags: django
categories: django
---

*我想在django中放一个脚本，然后循环执行他，该脚本会操作数据库，我懒得自己pymysql等方式写，就想用orm的方式，直接脚本中import models，但是呢，python xxxx执行后各种报错，说找不到环境变量，网上搜了下解决方案，也是差不多，但我就是没有调试出来。于是打算用django自带的方式执行命令。*

<!-- more -->

## 目录结构

1. 在app中创建/management/commands目录
2. 在commands目录里面创建py脚本

例如我的app叫做gp_volume，则在这个路径下创建/management/commands，然后放了两个脚本，一个是page_manager.py，一个是test.py。

```
.
|-- admin.py
|-- apps.py
|-- __init__.py
|-- management
|   `-- commands
|       |-- page_manager.py
|       |-- __pycache__
|       |   |-- page_manager.cpython-36.pyc
|       |   `-- test.cpython-36.pyc
|       `-- test.py

```

## 脚本编写

1. 脚本代码需要封装在Command这个类里面，且继承BaseCommand类
2. 对Command类的handle函数进行重写

拿个page_manager.py举例

```
from django.core.management.base import BaseCommand, CommandError
from gp_volume.models import Code, Volume, Page
import datetime


# 编写Command类，并且继承BaseCommand
class Command(BaseCommand):

    # 重写handle函数
    def handle(self, *args, **options):
        code_list = Code.objects.filter(status='o', date=str(datetime.date.today()))
        for code in code_list:
            print(code.code)
```

## 脚本执行

1. python3 manage.py ${script_name}

例如跑page_manager.py，无需脚本后缀名

```
python3 manager page_manager
```

## 传参给脚本

1. 定义add_arguments方法
2. 使用options['key']获取传入的参数

test.py例子

```
from django.core.management.base import BaseCommand, CommandError
from gp_volume.models import Code, Volume, Page
import datetime

class Command(BaseCommand):
    def add_arguments(self, parser):
        # nargs='+' 表示至少要有一个参数
        parser.add_argument('code_id', nargs='+', type=str)
        parser.add_argument(
            '--delete',
            # store_True表示参数如果不写，默认没有。
            action='store_True',
            help='Delete poll instead of closing it',
        )

    def handle(self, *args, **options):
        # 判断是否存在delete参数
        if options['delete']:
            for code in options['code_id']:
                Code.objects.get(code=code).delete()
        else:
            print('no args')
```

执行命令

```
python3 manage.py test --delete xxxxxxx
```

refer

> https://docs.djangoproject.com/en/2.2/howto/custom-management-commands/