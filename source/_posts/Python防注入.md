---
title: Python防注入
date: 2019-01-30 18:41:38
tags: python3
---

## 注入案例：

```python
import MySQLdb

db = MySQLdb.connect(host="localhost",
user="",
passwd="",
db="")

cur = db.cursor()

platform = input('Enter language: ')

cur.execute("SELECT * FROM platforms WHERE language = '%s';" % platform)
for row in cur.fetchall():
print(row)

db.close()

```
<!-- more -->

上述代码，让用户输入想查询的language，如果用户按套路，比如输入Ruby，则可以正常查询。

执行代码为：
```
SELECT * FROM platforms WHERE language = 'Ruby';
```

但如果搞事情输入Ruby'; DROP TABLE platforms;那么platforms表被删除。
执行代码为：
```
SELECT * FROM platforms WHERE language = 'Ruby'; DROP TABLE platforms;';
```

## 防止sql注入

代码改写为如下:
```
import MySQLdb

db = MySQLdb.connect(host="localhost",
user="",
passwd="",
db="")

cur = db.cursor()

platform = raw_input('Enter language: ')

cur.execute("SELECT * FROM platforms WHERE language = %s;", (platform,))
for row in cur.fetchall():
print (row)

db.close()
```

这边%s是占位符，和**字符串format的方式不同，而且后面的元组前面也不需要%符号，即便是数字，也是用%s来占位。**

## 防sql原因

之所以能防sql是因为execute函数会对传入的args内容预处理。
```
def mogrify(self, query, args=None):
    """
    Returns the exact string that is sent to the database by calling the
    execute() method.

    This method follows the extension to the DB API 2.0 followed by Psycopg.
    """
    conn = self._get_db()
    if PY2:  # Use bytes on Python 2 always
        query = self._ensure_bytes(query, encoding=conn.encoding)

    if args is not None:
        query = query % self._escape_args(args, conn)
```

execute后续调用一些函数，比如下面`escape_string`函数。(能力有限，前面几级调用不是非常看得懂。)

```
def escape_string(self, s):
    if (self.server_status &
            SERVER_STATUS.SERVER_STATUS_NO_BACKSLASH_ESCAPES):
        return s.replace("'", "''")
    return converters.escape_string(s)
```

refer

> https://blog.sqreen.io/preventing-sql-injections-in-python/