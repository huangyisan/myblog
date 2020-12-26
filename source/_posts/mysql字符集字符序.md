---
title: mysql字符集字符序
date: 2019-01-10 13:10:12
tags: mysql
---

Emmmm....数据库默认配置，建库没指定字符集，然后你懂得，所有库，表，部分字段字符集都是latin1。

<!-- more -->

MariaDB version 10.1.36

**数据库分字符集(character)和字符序(collation)**
* character定义了字符以及字符的编码。
* collation定义了字符的比较规则。

**有四个地方涉及到字符集和字符序**
- 服务器端(server level)
- 数据库(database level)
- 表(table level)
- char varchar text类型的字段(column level)

**如果都未进行指定，采用何种character和collation，则默认情况为character=latin1, collation=latin1_swedish_ci**

## 字符集
1. 查看当前支持的字符集`SHOW charsets`，Default collation字段告知了，该字符集所用的默认字符序。
```
mysql> SHOW charset;
+----------+-----------------------------+---------------------+--------+
| Charset  | Description                 | Default collation   | Maxlen |
+----------+-----------------------------+---------------------+--------+
| big5     | Big5 Traditional Chinese    | big5_chinese_ci     |      2 |
| dec8     | DEC West European           | dec8_swedish_ci     |      1 |
| cp850    | DOS West European           | cp850_general_ci    |      1 |
| hp8      | HP West European            | hp8_english_ci      |      1 |
| koi8r    | KOI8-R Relcom Russian       | koi8r_general_ci    |      1 |
...
..
.
```

2. 查看server level当前的字符集`SHOW VARIABLES LIKE "character_set_server"`，查看server level当前的字符序`SHOW VARIABLES LIKE "collation_server"`

3. 修改server level字符集的方法:
- 修改配置文件
- 编译的时候
- set 全局变量命令。但这种情况重启会失效。

2. 如果创建库，或者表，或者字段，或者配置文件my,cnf中只指定了字符集，则默认的字符序为该字符集所对应的默认字符序。


## 字符序
1. 查看当前支持的字符序`SHOW collation`, Default字段存在Yes的，表示该字符集默认的default值。比如latin1默认的字符序为latin1_swedish_ci

```
mysql> SHOW collation;
+--------------------------+----------+-----+---------+----------+---------+
| Collation                | Charset  | Id  | Default | Compiled | Sortlen |
+--------------------------+----------+-----+---------+----------+---------+
| big5_chinese_ci          | big5     |   1 | Yes     | Yes      |       1 |
| big5_bin                 | big5     |  84 |         | Yes      |       1 |
| dec8_swedish_ci          | dec8     |   3 | Yes     | Yes      |       1 |
| dec8_bin                 | dec8     |  69 |         | Yes      |       1 |
| cp850_general_ci         | cp850    |   4 | Yes     | Yes      |       1 |
| cp850_bin                | cp850    |  80 |         | Yes      |       1 |
| hp8_english_ci           | hp8      |   6 | Yes     | Yes      |       1 |
| hp8_bin                  | hp8      |  72 |         | Yes      |       1 |
| koi8r_general_ci         | koi8r    |   7 | Yes     | Yes      |       1 |
| koi8r_bin                | koi8r    |  74 |         | Yes      |       1 |
| latin1_german1_ci        | latin1   |   5 |         | Yes      |       1 |
| latin1_swedish_ci        | latin1   |   8 | Yes     | Yes      |       1 |
| latin1_danish_ci         | latin1   |  15 |         | Yes      |       1 |
```

2. 如果创建库，或者表，或者字段，或者配置文件my,cnf中只指定了字符序，则默认的字符集为该字符序所对应的字符集。

3. 字符序表示的含义
* 一般来说分为三段，也存在一段或者两段的情况，常见的三段如`utf8mb4_general_ci`,两段的如`utf8mb4_bin`(**这类情况，其实只存在第一段和第三段，第二段不存在**)
* 第一段代表字符集。
* 第二段代表语言(chinese,swedish),也有general这种通用的，或者unicode类型。
* 第三段代表是否敏感，是否为bin。

4. 对于第三段的解释
```
_ai	Accent insensitive
_as	Accent sensitive
_ci	Case insensitive
_cs	case-sensitive
_bin	Binary
```

* Accent是否为sensitive表现为，如果为sensitive，则比较a和á是不同的，如果为insensitive则a和á比较为相同。
* Case insensitive为大小写不敏感，case-sensitive为大小写敏感。

## 字符集和字符序的继承顺序
1. 数据库服务，建库，建表，建字段，倘若其中有指定character和collation，则`字段`继承`表`，`表`继承`库`，`库`继承`数据库服务`。比如建库指定了字符集为utf8，那么该库下面的表如果不指定字符集，则表的字符集也为utf8，char、varchar、text的字段字符集也是utf8。
2. **有个例外，如果修改了表， 那么该表下面的字段的字符集和字符序也会变成表的字符集和字符序。**

## 修改查看字符集命令：

* 修改运行环境：

    ```
    SET character_set_server = utf8mb4
    set character_set_connection = utf8mb4
    set character_set_database = utf8mb4
    set character_set_results = utf8mb4
    ```

* 修改库:

    ```
    ALTER DATABASE dbname CHARACTER SET utf8mb4 COLLATE  utf8mb4_unicode_ci;
    
    验证语句 
    show create database dbname;

    ```
    
* 修改表:
    ```
    1. dir varchar(255) -> varchar(191)  mysql5.6的版本需要修改。不保证所有版本都需要修改。
    ALTER TABLE dir_stats MODIFY dir VARCHAR(191);
    2. 修改字段类型utf8mb4
    alter table tablename convert to character set utf8mb4 collate utf8mb4_unicode_ci;
    
    验证语句
    SHOW FULL COLUMNS FROM dbname.tablename;
    ```


refer:
> https://www.cnblogs.com/chyingp/p/mysql-character-set-collation.html
> https://mariadb.com/kb/zh-cn/setting-character-sets-and-collations
> https://dev.mysql.com/doc/refman/8.0/en/charset-database.html
> http://zarez.net/?p=719

