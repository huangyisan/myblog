---
title: LeetCode 实现strStr()
date: 2019-01-23 23:58:56
tags: leetcode
categories: leetcode

---

## 需求

实现 strStr() 函数。

给定一个 haystack 字符串和一个 needle 字符串，在 haystack 字符串中找出 needle 字符串出现的第一个位置 (从0开始)。如果不存在，则返回  -1。

## 示例

```
输入: haystack = "hello", needle = "ll"
输出: 2
```

```
输入: haystack = "aaaaa", needle = "bba"
输出: -1
```

## 说明

当 needle 是空字符串时，我们应当返回什么值呢？这是一个在面试中很好的问题。

对于本题而言，当 needle 是空字符串时我们应当返回 0 。这与C语言的 strstr() 以及 Java的 indexOf() 定义相符。

## 解题思路
python非常简单，直接使用find命令就可以查询到指定字符串第一次出现的position。

## 解题代码

```
class Solution(object):
    def strStr(self, haystack, needle):
        """
        :type haystack: str
        :type needle: str
        :rtype: int
        """
        return haystack.find(needle)

```

refer
> https://leetcode-cn.com/problems/implement-strstr/
