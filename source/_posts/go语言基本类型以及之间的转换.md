---
title: go语言基本类型以及之间的转换
date: 2020-06-14 16:18:27
tags: go
---



## go语言基本类型

#### 数字类型

**1. 有符号整型**

![有符号型](https://image.kirakirazone.com/image/有符号整型.png)



**2. 无符号整型**

![无符号型](https://image.kirakirazone.com/image/无符号整型.png)



**3. byte和rune类型**

1. byte类型实则为unit8类型，他用来存放ASCII字符。

2. rune类型实则为int32类型，他用来存放以utf-8编码的unicode字符类型。

3. byte和rune都是用单引号引起来，比如'A', '黄'。

4. **如果没有指定类型，则默认为rune类型**，比如var char = 'A', 此时char是rune类型。

5. **如果要用byte类型，则需要声明的时候指定byte类型**，比如var char byte = 'A'，此时char是byte类型。

6. 因为byte和rune类型，实际是整数，所以如果对于'A'的存放使用byte，则是存了65这个值。

   

**4. 浮点型**

![浮点型](https://image.kirakirazone.com/image/浮点型.png)

​	**float32**

​	单精度，存储占用4个字节，也即4*8=32位，其中1位用来符号，8位用来指数，剩下的23位表示尾数。

![单精度](https://image.kirakirazone.com/单精度)

​	**float64**

​	双精度，存储占用8个字节，也即8*8=64位，其中1位用来符号，11位用来指数，剩下的52位表示尾数。

![双精度](https://image.kirakirazone.com/双精度)


​       

#### 字符类型

1. 字符类型strings是一串byte，使用双引号，或者单反引号来表示，`"hello"`, \`hello\`。

2. 双引号内的字符串，不可以跨行，且会受到转义字符的影响，比如\n,\t，如果想要不受影响，则使用单反引号。



#### 布尔类型

1. bool类型只有false和true两种，且不可以像python那样存在隐式转换。



## 类型之间的转换

1. go语言不存在类型之间的隐式转换，都需要进行显式转换。
2. 转换可以从小范围往大范围转换，也可以大范围往小范围转换，**但大范围转小范围往往会导致结果溢出**。



### 数字类型之间的转换

#### 只需要进行T(v)的方式即可

1. int32转int64

   ```go
   package main
   
   import "fmt"
   
   func main() {
   	var num32 int32 = 123
   	num64 := int64(num32)
   	fmt.Printf("转换前的值为%d, 类型为%T\n转换后的值为%d, 类型为%T\n", num32, num32, num64, num64)
   }
   
   
   output
   转换前的值为123, 类型为int32
   转换后的值为123, 类型为int64
   ```

   

2. int32转float32

   ```go
   package main
   
   import "fmt"
   
   func main() {
   	var num32 int32 = 123
   	num64 := float32(num32)
   	fmt.Printf("转换前的值为%d, 类型为%T\n转换后的值为%f, 类型为%T\n", num32, num32, num64, num64)
   }
   
   output
   转换前的值为123, 类型为int32
   转换后的值为123.000000, 类型为float32
   
   ```



3. float64转int64，**会把小数部分掐掉**

   ```go
   package main
   
   import "fmt"
   
   func main() {
   	var num32 float64 = 123.756
   	num64 := int64(num32)
   	fmt.Printf("转换前的值为%f, 类型为%T\n转换后的值为%d, 类型为%T\n", num32, num32, num64, num64)
   }
   
   output
   转换前的值为123.756000, 类型为float64
   转换后的值为123, 类型为int64
   
   ```

   



4. 大范围转小范围容易产生结果溢出

   ```go
   package main
   
   import "fmt"
   
   func main() {
   	var num32 int64 = 999999
   	num64 := int8(num32) //转换成了小范围int8
   	fmt.Printf("转换前的值为%d, 类型为%T\n转换后的值为%d, 类型为%T\n", num32, num32, num64, num64)
   }
   
   output 结果溢出导致不是期望的结果
   转换前的值为999999, 类型为int64
   转换后的值为63, 类型为int8
   ```

   

### 转换为字符串

1. 使用`fmt.Sprintf`方式进行转换, 该方法传入对象，以及对象所属类型，然后转换成string类型返回。

   ```go
   package main
   
   import "fmt"
   
   func main() {
   	var num32 int32 = 64
   	var flo32 float32 = 12.34
   	var Bool bool = false
   	var Byte byte = 'h'
   	var Rune rune = '黄'
   
   	// 传入类型以及内容
   	str := fmt.Sprintf("%d", num32) // num32是%d类型，转换为string类型返回给str
   	fmt.Printf("转换后得到的内容为%v, 类型为%T\n",str,str)
   
   	str = fmt.Sprintf("%f", flo32) // %f, 表示浮点类型, 这里会对精度补足0，所以如果要作为字符串的话，还需要把末尾的0去掉
   	fmt.Printf("转换后得到的内容为%v, 类型为%T\n",str,str)
   
   	str = fmt.Sprintf("%t", Bool) // %t，表示false或者true
   	fmt.Printf("转换后得到的内容为%v, 类型为%T\n",str,str)
   
   	str = fmt.Sprintf("%c", Byte) // %c，表示字符类型
   	fmt.Printf("转换后得到的内容为%v, 类型为%T\n",str,str)
   
   	str = fmt.Sprintf("%c", Rune) // %c，表示字符类型
   	fmt.Printf("转换后得到的内容为%v, 类型为%T\n",str,str)
   
   }
   
   output:
   转换后得到的内容为64, 类型为string
   转换后得到的内容为12.340000, 类型为string
   转换后得到的内容为false, 类型为string
   转换后得到的内容为h, 类型为string
   转换后得到的内容为黄, 类型为string
   
   ```

   

2. 使用`strconv`进行转换

   [strconv使用文档](https://studygolang.com/pkgdoc)

   ```go
   package main
   
   import (
   	"fmt"
   	"strconv"
   )
   
   func main() {
   	var num32 int32 = 64
   	var flo32 float32 = 12.34
   	var Bool bool = false
   
   	// 传入类型以及内容
   	str := strconv.FormatInt(int64(num32), 10) // 告诉带转换的num32为10进制。
   	fmt.Printf("转换后得到的内容为%v, 类型为%T\n",str,str)
   
   	str = strconv.FormatFloat(float64(flo32), 'f', 3, 32) //格式为float类型，保留10位小数，原数据是float64类型
   	fmt.Printf("转换后得到的内容为%v, 类型为%T\n",str,str)
   
   	str = strconv.FormatBool(Bool) // 只需要传入布尔类型即可， 根据内容返回true还是false
   	fmt.Printf("转换后得到的内容为%v, 类型为%T\n",str,str)
   	
   }
   
   ```




### 转换为Bool类型

   `func ParseBool`

   [func ParseBool参考](https://github.com/golang/go/blob/master/src/strconv/atob.go?name=release#10)

   返回字符串表示的Bool值。**它接受字符串1、0、t、f、T、F、true、false、True、False、TRUE、FALSE；否则返回错误。**返回两个值，一个是转换后的值，一个是err。

   

   ```go
   package main
   
   import (
   	"fmt"
   	"strconv"
   )
   
   func main() {
   	var str string = "false"
   	var numTrue string = "1"
   
   	strBool, _ := strconv.ParseBool(str)
   	numBool, _ := strconv.ParseBool(numTrue)
   
   	fmt.Printf("strBool值为%t, numBool值为%t\n", strBool, numBool)
   }
   
   ```

   

### 字符串转换为数字类型

1. `strconv.ParseInt()`方式转换为有符号int类型

   * **strconv.ParseInt()的bitSize参数不会将字符串转换为您选择的类型, 而只是在此处将结果限制为特定的“位”，如果想要得到你要的int类型必须手动转换类型。**
   * 接受正负号。
   * 具体参考[func ParseInt](https://studygolang.com/static/pkgdoc/pkg/strconv.htm#pkg-index)
   * strconv.ParseUint()该方法转换为无符号int类型，**不接受正负号**

   

   ```go
   package main
   
   import (
   	"fmt"
   	"strconv"
   )
   
   func main() {
       var str string = "123"
   
       num, _ := strconv.ParseInt(str, 10, 64)
       unum, _ := strconv.ParseUint(str, 10, 64)
   
       fmt.Printf("num值为%d, num类型为%T\n", num,num)
       fmt.Printf("unum值为%d, unum类型为%T\n", unum,unum)
   }
   
   
   output:
   num值为123, num类型为int64
   unum值为123, unum类型为uint64
   ```

   

2. `strconv.ParseFloat()`将转换为float类型

   * 得到的
   * 具体参考[func ParseFloat](https://github.com/golang/go/blob/master/src/strconv/atof.go?name=release#533) 
   * bitSize指定了期望的接收类型，32是float32（返回值可以不改变精确值的赋值给float32），64是float64。

   ```go
   package main
   
   import (
       "fmt"
       "strconv"
   )
   
   func main() {
       var str string = "123.33"
   
       num, _ := strconv.ParseFloat(str, 64)
   
       fmt.Printf("num值为%f, num类型为%T\n", num,num)
   }
   
   output:
   num值为123.330000, num类型为float64
   ```

   

### String类型和byte类型互转

1. string无法直接转换为byte，**需要转换为[]byte进行处理**。

2. byte转换成string，可以直接使用`string()`方法转换

   ```go
   package main
   
   import "fmt"
   
   func main() {
   	str := "huangyisan"
   
   	// 转换成byte数组, 可以处理英文和数组 ,[]byte按照字节来处理,而汉字占用3个字节
   	arr1 := []byte(str)
   	arr1[0] = 'z'
       fmt.Println(arr1)
   	str = string(arr1) // 将[]byte转换为string类型
   	fmt.Println(str)
   }
   
   output:
   [122 117 97 110 103 121 105 115 97 110] // 因为byte的实现是uint8, 所以这边打印出来的是数字。
   zuangyisan
   
   ```

   

### string类型和rune类型互转

1. string类型转换成rune类型，跟byte一样，**需要先作为切片**。

2. rune类型转string类型，可以直接使用`string()`方法。

   ```go
   package main
   
   import "fmt"
   
   func main() {
       str := "huangyisan"
       //转换成rune数组, 可以处理中文
       arr2 := []rune(str)
       fmt.Println(arr2)
       arr2[0] = '黄'
       str = string(arr2) // 使用string将rune切片转换为string类型。
       fmt.Println(str)
   }
   
   
   output:
   
   [104 117 97 110 103 121 105 115 97 110]  // 因为byte的实现是int32, 所以这边打印出来的是数字。
   黄uangyisan
   ```

   

