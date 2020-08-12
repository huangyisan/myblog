---
title: 从无法加载JAVA_HOME说起
date: 2018-12-25 19:45:38
tags: linux
categories: system
---

这几天在做jenkins cicd的事儿，用sudo的方式启动tomcat，直接报出无法找到JAVA_HOME。当时挺纳闷的，因为我在/etc/profile里面是添加了JAVA_HOME。
```
[root@ccc bin]# sudo ./catalina.sh start
Neither the JAVA_HOME nor the JRE_HOME environment variable is defined
At least one of these environment variable is needed to run this program
[root@ccc bin]# tail -n 5 /etc/profile

export JAVA_HOME=/tool/jdk1.8.0_144
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
export JAVA_HOME CLASSPATH PATH
```

如此如此，出现了两个疑问。
1. 为什么/etc/profile的内容无法被加载？
2. 在/etc/profile里面写入jdk环境变量是否合适？

## 为什么/etc/profile的内容无法被加载？

先说下一个概念，linux的用户交互模式。在linux中用户交互模式可以分为两类：
1. Interactive Shell
2. Non-Interactive Shell

Interactive Shell 顾名思义，就是登陆用户可以和shell进行交互的，比如你用xshell上一台服务器，出现的terminal就是属于Interactive Shell方式。
Non-Interactive Shell 非交互的模式，比如用crontab的方式执行一个shell脚本。

那么问题就来了，这两种模式的环境变量从哪里去获取呢？
1. Interactive Shell登录情况

```
execute /etc/profile
IF ~/.bash_profile exists THEN
    execute ~/.bash_profile
ELSE
    IF ~/.bash_login exist THEN
        execute ~/.bash_login
    ELSE
        IF ~/.profile exist THEN
            execute ~/.profile
        END IF
    END IF
END IF
```

**一目了然，入口为/etc/profile文件**。
其中在.bash_profile里面还判断是否存在~/.bashrc，如果存在则加载~/.bashrc。

```
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
```

还没完，在执行~/.bashrc的时候里面继续判断是否存在/etc/bashrc，如果存在则执行/etc/bashrc。

```
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
```

顺带一说，当用户退出Interactive Shell的时候，执行~/.bash_logout内容。所以可以在退出的时候定义一些行为。

```
IF ~/.bash_logout exists THEN
    execute ~/.bash_logout
END IF
```

### 总结下Interactive Shell的顺序：
1. /etc/profile
2. ~/.bash_profile
3. ~/.bashrc
4. /etc/bashrc
5. ~/.bash_login
6. ~/.profile
7. ~/.bash_logout (当且仅当退出Interactive Shell的时候执行)


2. Non-Interactive Shell的情况

```
IF ~/.bashrc exists THEN
    execute ~/.bashrc
END IF
```

直接去执行的~/.bashrc，该文件也会判断是否存在/etc/bashrc，存在则执行/etc/bashrc。

### 总结下Non-Interactive Shell的顺序：
1. ~/.bashrc
2. /etc/bashrc



**看似原因好像是因为`sudo ./catalina.sh start`进入了Non-Interactive Shell，从而没加载/etc/profile，其实并不是这样的。**
**sudo在这边搞出了幺蛾子？**

### sudo做了啥？
命令输入visudo，有那么一节内容：

```
# Preserving HOME has security implications since many programs
# use it when searching for configuration files. Note that HOME
# is already set when the the env_reset option is enabled, so
# this option is only effective for configurations where either
# env_reset is disabled or HOME is present in the env_keep list.
#
Defaults    always_set_home

Defaults    env_reset
Defaults    env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS"
Defaults    env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"
Defaults    env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"
Defaults    env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"
```

**其行为会将env reset，但是会保留部分环境变量。这一行为导致了`sudo ./catalina.sh start`无法寻找到jdk变量。**

比较差劲的解决方法：
man一下sudo，有个-E的参数，能保留之前的环境变量，但是不推荐这样做，因为有安全隐患：

```
     -E          The -E (preserve environment) option indicates to the security policy that the user wishes to preserve their existing
                 environment variables.  The security policy may return an error if the -E option is specified and the user does not have
                 permission to preserve the environment.
```

```
[root@ccc bin]# sudo -E ./catalina.sh start
Using CATALINA_BASE:   /opt/mixcdn-tomcat
Using CATALINA_HOME:   /opt/mixcdn-tomcat
Using CATALINA_TMPDIR: /opt/mixcdn-tomcat/temp
Using JRE_HOME:        /tool/jdk1.8.0_144
Using CLASSPATH:       /opt/mixcdn-tomcat/bin/bootstrap.jar:/opt/mixcdn-tomcat/bin/tomcat-juli.jar
Tomcat started.
```

好的解决方法在下面：

## 在/etc/profile里面写入jdk环境变量是否合适？

针对部署tomcat的jdk环境，很多文档，包括我自己，之前也是从别人那边拿来的部署jdk文档，将jdk环境变量写入/etc/profile，等文件中，这个观念基本上贯穿了我整个运维生涯。

其实官方给出了写法，在catalina.sh里面:

```
# Control Script for the CATALINA Server
#
# Environment Variable Prerequisites
#
#   Do not set the variables in this script. Instead put them into a script
#   setenv.sh in CATALINA_BASE/bin to keep your customizations separate.
#
#   CATALINA_HOME   May point at your Catalina "build" directory.
#
#   CATALINA_BASE   (Optional) Base directory for resolving dynamic portions
#                   of a Catalina installation.  If not present, resolves to

....
...
.
# Ensure that any user defined CLASSPATH variables are not used on startup,
# but allow them to be specified in setenv.sh, in rare case when it is needed.
CLASSPATH=

if [ -r "$CATALINA_BASE/bin/setenv.sh" ]; then
  . "$CATALINA_BASE/bin/setenv.sh"
elif [ -r "$CATALINA_HOME/bin/setenv.sh" ]; then
  . "$CATALINA_HOME/bin/setenv.sh"
fi

....
...
.
```

就是在tomcat/bin目录下面，写入一个setenv.sh文件里面写入需要的环境变量，当运行catalina.sh启动脚本的时候，其会进行执行该setenv.sh文件，当前我的版本是1.8，非特殊情况其已经不需要写入CLASSPATH。(据说jdk1.5之后就不需要写入CLASSPATH了。)

```
[root@ccc bin]# cat setenv.sh
export JAVA_HOME=/tool/jdk1.8.0_144
export PATH=$PATH:$JAVA_HOME/bin
```

多看官方文档，多看服务自带脚本还是非常有必要的。


Refer:
> https://www.thegeekstuff.com/2008/10/execution-sequence-for-bash_profile-bashrc-bash_login-profile-and-bash_logout/
> https://bencane.com/2013/09/16/understanding-a-little-more-about-etcprofile-and-etcbashrc/
> https://stackoverflow.com/questions/8633461/how-to-keep-environment-variables-when-using-sudo
> https://segmentfault.com/q/1010000011528636/a-1020000011538128

下次写sudo su两个命令。
