---
title: JWT认证的实现
date: 2020-02-29 22:41:38
tags: [python3, vue, js]
---

## 什么是JWT，以及原理

网上有大把解释JWT认证原理的，直接看refer部分。



## JWT认证

1. 当用户登陆的时候，后端根据部分字段进行签名，然后将签名得到的数据返回给用户。
2. 用户下一次请求数据的时候，在请求头的authentication字段携带token。
3. 服务端收到token后进行解密，前两段用私钥签名的结果跟第三段对比，看是否一致，如果一致，则判定当前用户合法，反之则非法。
4. JWT的token为三段，前两段用base64编码，可以解开，第一段是描述认证方式和算法，第二段就是具体的一些信息，第三段为服务端私钥根据前两段内容进行的签名，也就是加密部分。

<!-- more -->

## JWT后端部分代码

1. 后端使用python写，求快，直接用的sanic库，以下为主要代码，只求结果正确。

2. 主要逻辑：

   1. 登录认证通过，则后端根据username以及一些基本信息生成token，然后返回给前端

      

   ```python
   ...
   ..
   .
       token = jwt.encode(payload, 'today', headers=jwt_headers, algorithm='HS256').decode()
   		# 若用户名和密码为admin， 则认为认证通过
       if username == 'admin' and password == 'admin':
           return json({'code': 200, 'info': 'authSuccess','access_token': token, 'account_id': username})
       else:
           return json({'code': 401, 'info': 'authFaildd'})
   ...
   ..
   .
   ```

   2. 其他但凡和后端存在数据交互的，则进行token的认证，将该方法作为装饰器。

      

      ```python
      def check(func):
          print('执行check')
          def wrapper(request):
              print('执行wrapper')
              jwt_headers = {
                  "alg": "HS256",
                  "typ": "JWT"
              }
      
              token = request.headers.get('authorization')
              if token:
                  token = token.split(' ')[-1]
                  try:
                      payload = jwt.decode(token, 'today', audience='yisan.com', headers=jwt_headers, algorithms=['HS256'])
                      if payload:
                          return func(request)
                      return json({'code': 401, 'info': 'checkFailed'})
                  except Exception as e:
                      print(e)
                      return json({'code': 401, 'info': 'checkFailed'})
      
                  # 具体要请求的接口数据
      
              return json({'code': 405, 'info': '函数没有返回值'})
          return wrapper
      ```



## JWT前端部分代码

1. 主要使用axios的响应拦截器，对返回json数据的code值进行判断。

2. 主要逻辑

   1. axios相应拦截器

      ```javascript
        instance.interceptors.response.use(res => {
          const code = res.data.code
          console.log(document.location)
          console.log(res)
          // 后端返回401, 且当前uri不是/login, 则跳转到login页面
          if (code === 401 && document.location.pathname !== '/login') {
            console.log('登陆失败或失效')
            sessionStorage.removeItem('token')
            router.push('/login')
            return res.data
           // 后端返回401， 且当前uri是/login, 则不跳转，防止死循环
          } else if (code === 401 && document.location.pathname === '/login') {
            // console.log('不跳转了')
            // return false
            return res.data
          }
          return res.data
        })
      
      ```

   2. /login页面，在created阶段，发送token验证请求，如果当前为登陆状态，则跳转至/homepage

      ```javascript
          created() {
            this.token = sessionStorage.getItem('token')
            tokenCheck(this.token).then(res => {
              console.log(res)
              if (res.code === 200) {
                this.$router.push('/homepage')
              }
            })
          }
      
      ```



## GitHub仓库地址

> https://github.com/huangyisan/simulator_jwt_auth.git



refer

> https://zhuanlan.zhihu.com/p/70275218
>
> https://segmentfault.com/a/1190000010312468
>
> https://jasonwatmore.com/post/2018/07/06/vue-vuex-jwt-authentication-tutorial-example
>
> https://juejin.im/post/5ce3e9146fb9a07eba2c1258