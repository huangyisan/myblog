---
title: split函数
date: 2018-12-29 12:41:38
tags: python3
---

## 一道领扣的题
给定一个仅包含大小写字母和空格 ' ' 的字符串，返回其最后一个单词的长度。
如果不存在最后一个单词，请返回 0 。
说明：一个单词是指由字母组成，但不包含任何空格的字符串。

示例:
```
输入: "Hello World"
输出: 5
```

写出的其中一种答案是：
```
class Solution(object):
    def lengthOfLastWord(self, s):
        """
        :type s: str
        :rtype: int
        """

        slist = s.split()
        print(slist)
        if slist == []:
            return 0
        return len(slist[-1])
```

## split(" ") 和 split()

起先我认为split(" ")和split()的作用是一样的，都是以空格进行分割。
以至于一开始做上面领扣的题一直都有问题。

然后手工验证了下两者的情况：
* split(" ")的情况
```
>>> " a   ".split(" ")
['', 'a', '', '', '']
```

* split()的情况
```
>>> " a   ".split()
['a']
```

* 查了下split()的用法
```
S.split([sep [,maxsplit]]) -> list of strings

Return a list of the words in the string S, using sep as the delimiter string. If maxsplit is given, at most maxsplit splits are done. If sep is not specified or is None, any whitespace string is a separator and empty strings are removed from the result.
```

**也就是说，如果sep不填写，那么split()执行两个行为：**
1. 以任何whitespace字符串作为分隔符。
2. 除所有的empty string。

empty string就是`not xxx`返回结果为False的字符串,包括""。

refer:
> https://leetcode-cn.com/problems/length-of-last-word/
> help(str.split)

