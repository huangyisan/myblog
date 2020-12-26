---
title: LeetCode 最后一个单词长度
date: 2019-01-24 12:27:56
tags: leetcode
categories: leetcode

---

## 需求

给定一个仅包含大小写字母和空格 ' ' 的字符串，返回其最后一个单词的长度。

如果不存在最后一个单词，请返回 0 。

<!-- more -->

## 说明

一个单词是指由字母组成，但不包含任何空格的字符串。

## 示例

```
输入: "Hello World"
输出: 5
```

## 解题思路
1. 两种情况，一种是为空，第二种是非空字符串。
2. 字符串为空，则直接返回0，非空字符串，则返回最后一个单词。
3. python用split()方法，默认以空格，制表符等分割字符串，成为一个list。

## 解题代码

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

refer:
> https://leetcode-cn.com/problems/length-of-last-word/submissions/