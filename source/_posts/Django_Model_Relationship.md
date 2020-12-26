---
title: Django Model Relationship
date: 2019-11-04 13:58:56
tags: django
---

*好久没写了，这次用阴阳师来举例子。*

## Django Model的三种Relationship
1. 一对一 (关键词 **OneToOneField**)
2. 一对多 (关键词 **ForeignKey**) *没有OneToManyField这种写法*
3. 多对多 (关键词 **ManyToManyField**)

<!-- more -->

## 代码和关系


```python
from django.db import models

# Create your models here.

# 定义稀有度，五个等级，n r sr ssr sp
class Rare(models.Model):
    N = 'n'
    R = 'r'
    SR = 'sr'
    SSR = 'ssr'
    SP = 'sp'

    LEVEL_CHOICES = [
        (N,'N'),
        (R,'R'),
        (SR,'SR'),
        (SSR,'SSR'),
        (SP,'SP'),
    ]
    # one to one relationship with formula

    level = models.CharField(max_length=4, choices=LEVEL_CHOICES,default=SSR,unique=True)

    def __str__(self):
        return self.level

# 定义式神名称
class Formula(models.Model):
    # 一对多定义
    rare = models.ForeignKey(Rare, on_delete=models.CASCADE)
    name = models.CharField(max_length=10, unique=True, primary_key = True)

    def __str__(self):
        return self.name

# 定义cp字段
class Lover(models.Model):
    # 一对一定义
    formula = models.OneToOneField(Formula, on_delete=models.SET_NULL,null=True)
    lover_name = models.CharField(max_length=10,unique=True)

    def __str__(self):
        return self.lover_name

# 定义御魂套字段
class Soul(models.Model):
    # 多对多定义
    formula = models.ManyToManyField(Formula)
    # 御魂套名称
    set = models.CharField(max_length=10,unique=True)

    def __str__(self):
        return self.set
```

1. 式神和其cp为**一对一**关系，酒吞置于红叶，鲤鱼精至于河童。
2. 稀有度和式神为**一对多**关系。 一个种稀有度能对应多个式神，但一个式神只能有一种稀有度。
3. 御魂套和式神为**多对多**关系。一套御魂可以给多个式神使用，一个式神也可以使用多套御魂。

## 给数据库创建一些数据

### 创建的方法

1. 使用对象属性来创建
2. 使用objects来创建

#### 使用对象属性创建

**如果是创建自身的数据，则对象要调用save()，如果是创建关联性数据，则无需调用save()**

```
创建了稀有度为n的数据
>>> from onmyoji_models.models import *
>>> n = Rare(level='n')
>>> n.save()
>>> Rare.objects.all()
<QuerySet [<Rare: n>]>

```

#### 使用objects来创建

**使用objects来创建无需调用save()**

```
>>> Rare.objects.create(level='sr')
<Rare: sr>
>>> Rare.objects.all()
<QuerySet [<Rare: n>, <Rare: sr>]>
```

## 我该把关键词写在哪里


1. OneToOneField，一对一的情况，随便写。
2. ForeignKey，一对多的情况，写在**多的一方**，一种稀有度对应多个式神，所以ForeignKey定义在式神上，也就是class Formula上。
3. ManyToManyField，多对多的情况，任意写。
4. 建议将字段命名为关联class的小写，比如一对多，在class Formula需要定义一个ForeignKey字段和class Rare关联，则该字段名为'rare'。

```
rare = models.ForeignKey(Rare, on_delete=models.CASCADE)
```

## 三种关系的例子和相互读取

### 一对一

用酒吞和红叶举例子。

先创建酒吞，因为Formula有个rare字段的是关联了class Rare，所以要先获取rare的instance对象，将对象赋值给rare，然后创建酒吞。

**这边要注意的是，如果获取instance对象，则需要用到get()方法，倘若使用的是filter()，则获取的是一个query set对象，是不能够给rare赋值的。**

```
ssr = Rare.objects.get(level='ssr')
Formula.objects.create(name='JiuTun',rare=ssr)
<Formula: JiuTun>
```

接着在Lover中创建红叶。formula是个传入的对象，所以先get()获取到酒吞

```
>>> jiutun = Formula.objects.get(name='JiuTun')
>>> Lover.objects.create(lover_name='HongYe',formula=jiutun)
<Lover: HongYe>
```

相互之间访问数据

1. Formula到Lover
  * 对象属性方式，formula对象直接访问lover的lover_name字段

    ```
    >>> jiutun = Formula.objects.get(name='JiuTun')
    >>> jiutun.lover.lover_name
    'HongYe'
    ```

  * objects的方式,传入的formula是instance对象

    ```
    >>> jiutun = Formula.objects.get(name='JiuTun')
    >>> Lover.objects.get(formula=jiutun)
    <Lover: HongYe>
    >>> Lover.objects.get(formula=jiutun).lover_name
    'HongYe'
    ```

2. Lover到Formula
  * 对象属性方式，访问formula的name字段
    ```
    >>> hongye = Lover.objects.get(lover_name='HongYe')
    >>> hongye.formula.name
    'JiuTun'
    ```

  * objects的方式，传入的lover是instance对象
    ```
    >>> Formula.objects.get(lover=hongye)
    <Formula: JiuTun>
    >>> Formula.objects.get(lover=hongye).name
    'JiuTun'
    ```

### 一对多

通过对象属性的方式给给Formula添加鬼切式神。

```
>>> guiqie = Formula(name='GuiQie', rare=ssr)
<Formula: GuiQie>
>>> guiqie.save()
```

此时数据库内有数据了，formula为Guiqie,其rare为ssr。

相互之间访问数据

1. 从多(Formula)到一(Rare)

  * 对象属性方式
    ```
    >>> formula = Formula.objects.get(name='GuiQie')
    >>> formula.rare.level
    'ssr'
    ```
  
  * objects方式,访问Rare的level字段
    ```
    >>> Rare.objects.get(formula=formula)
    <Rare: ssr>
    >>> Rare.objects.get(formula=formula).level
    'ssr'
    ```

2. 从一(Rare)到多(Formula)

因为访问多，所以属性方法访问要用_set，objects对象访问则建议用filter()，因为get()遇到大于1个数据会报错。
因为是访问的多，所以得到结果是query set类型，访问具体数据，需要迭代进行访问。

  * 对象属性方式
  ```
    >>> ssr = Rare.objects.get(level='ssr')
    >>> ssr.formula_set.all()
    <QuerySet [<Formula: GuiQie>, <Formula: CiMuTongZi>]>
    >>> for i in ssr.formula_set.all():
    ...     print(i)
    ...
    GuiQie
    CiMuTongZi
  ```

  * objects方式
  ```
    >>> ssr = Rare.objects.get(level='ssr')
    >>> formulas = Formula.objects.filter(rare=ssr)
    >>> for i in formulas:
    ...     print(i)
    ...
    GuiQie
    CiMuTongZi
  ```

### 多对多

代码里，ManyToManyField定义在class Soul。

使用objects方式创建破势套和针女套

```
>>> Soul.objects.create(set='PoShi')
<Soul: Soul object (1)>
>>> Soul.objects.create(set='ZhenNv')
<Soul: Soul object (2)>
```

指定Soul(御魂)关联给Formula(式神)，**使用add的方式**

```
>>> zhennv = Soul.objects.get(set='ZhenNv')
>>> zhennv.formula.add(guiqie)
```

指定Formula(式神)关联给Soul(御魂)，**使用add的方式**

```
poshi = Soul.objects.get(set='PoShi')
>>> guiqie.soul_set.add(poshi)
```

将指定御魂(Soul)关联所有式神(Formula)，**使用set()方法**

```
>>> all = Formula.objects.all()
>>> poshi = Soul.objects.get(set='PoShi')
>>> poshi.formula.set(all)

```

将指定式神关联所有御魂，**使用set()方法**

```
>>> all = Soul.objects.all()
>>> Yi=Formula.objects.get(name='Yi')
>>> Yi.soul_set.set(all)
```


相互之间访问数据（好像不存在objects访问的方法，待考证）

1. 通过式神(Formula)获取御魂(Soul, ManyToManyField),使用_set.value()方式

    * 对象属性方式

    ```
    >>> guiqie.soul_set.values()
    <QuerySet [{'id': 1, 'set': 'ZhenNv'}]>
    ```

2. 通过御魂(Soul, ManyToManyField)查询式神(Formula)
   
   * 对象属性方式
   ```
    >>> poshi.formula.values()
    <QuerySet [{'rare_id': 4, 'name': 'GuiQie'}]>
   ```


refer
> https://imliyan.com/blogs/article/Django%E6%95%B0%E6%8D%AE%E6%A8%A1%E5%9E%8B%E5%AE%9E%E4%BE%8B/
> https://docs.djangoproject.com/en/2.2/ref/models/fields/#django.db.models.OneToOneField
> https://docs.djangoproject.com/en/2.2/ref/models/fields/#django.db.models.ForeignKey
> https://docs.djangoproject.com/en/2.2/ref/models/fields/#django.db.models.ManyToManyField
> https://docs.djangoproject.com/en/2.2/topics/db/examples/many_to_many/