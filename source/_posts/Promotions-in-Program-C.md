---
title: Promotions in Program C
date: 2019-01-08 00:00:12
tags: c
---

## scanf()函数不会自行提升成double类型，printf()函数会自行提升成double类型。
```
#include <stdio.h>

void main(void) {
    double num;
    printf("input a double type number: ");
    scanf("%f", &num);
    printf("the number is %f\n", num);
    printf("the number is %lf\n", num);
}

input a double type number: 1
the number is 0.000000
the number is 0.000000
```
**scanf()函数因为指向的是num的指针,所以不适用float promotions to double**

**scanf()若使用double类型，必须写成"%lf", 而printf()即便指定的是"%f",也会自行提升成double类型。**

```
#include <stdio.h>

void main(void) {
    double num;
    printf("input a double type number: ");
    scanf("%lf", &num);
    printf("the number is %f\n", num);
    printf("the number is %lf\n", num);
}


input a double type number: 1
the number is 1.000000
the number is 1.000000
```

## integer-promotions


refer:
> https://stackoverflow.com/questions/19952200/scanf-printf-double-variable-c
> http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1256.pdf [6.5.2.2 page-71]
> https://www.geeksforgeeks.org/integer-promotions-in-c/