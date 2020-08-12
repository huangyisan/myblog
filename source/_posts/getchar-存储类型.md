---
title: getchar()存储类型
date: 2018-12-20 23:07:44
tags: c
---

## getchar()返回类型声明为int类型

getchar()函数从文本流读入下一个输入字符，并且作为结果返回。

一个读取字符，并且打印的程序，当读取end of file(EOF)的时候结束。
```
#include <stdio.h>

int main (void)
{
    int c;
    c = getchar();
    while (c != EOF) {
        putchar(c);
        c = getchar();
    }
    return 0;
}
```

起先没搞明白为什么对c的声明是int类型，而不是char类型。

后来查阅资料得知，char类型的声明，会根据不同的编译器，或者不同的架构平台，可能成为unsigned char或者是signed char类型。

如果是unsigned char类型，**占8位，一个字节，其范围为0000 0000 ~ 1111 1111，即0 ~ 255**，那么无法存储EOF这个结束符，**EOF可以理解为数值-1(C89, C99, C11并没有给EOF定义一个具体的值，只是说EOF是一个负值常量)**。

而当被作为signed char类型，虽然其取值范围为-128 ~ +127，虽然能够存储EOF这个结束符，看似正常，但在linux的环境，会混淆char 255和EOF，导致输入数据的截断。

在linux平台运行以下程序

```
#include <stdio.h>

int main(void)
{
    char c;
    printf("Enter characters : ");
    while((c= getchar()) != EOF){
      putchar(c);
    }
    return 0;
}
```

输出结果可以发现\0377后面部分没有被打印。

```
[root@VM_31_91_centos ~]# gcc test.c && echo -e 'Hello world\0377And some more' | ./a.out
Enter characters : Hello world[root@VM_31_91_centos ~]#
```


**getchar()和putchar()初始返回的值都为int类型。**
**对于getchar()函数返回值的声明使用int类型**

## 打印出EOF的值

```
#include <stdio.h>

int main (void)
{
    int c;
    
    c = getchar();
    while (c == EOF) {
        
        printf("this is the value of EOF:%d",c);
        c = getchar();
        break;
    }
    return 0;
}
```

执行程序，按**CTRL+D发送EOF**，查看得到的数值为-1。





* refer
> https://stackoverflow.com/questions/18013167/why-must-the-variable-used-to-hold-getchars-return-value-be-declared-as-int
> https://stackoverflow.com/questions/35356322/difference-between-int-and-char-in-getchar-fgetc-and-putchar-fputc
> https://stackoverflow.com/questions/7119470/int-c-getchar
> The C Programming Language - By Kernighan and Ritchie

