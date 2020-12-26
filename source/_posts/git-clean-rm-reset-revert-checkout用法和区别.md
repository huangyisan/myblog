---
title: git clean/rm/reset/revert/checkout用法和区别
date: 2018-12-22 14:17:09
tags: git
---


## git的工作区和暂存区

先说下这两个概念：
**工作区**，就是你git仓库的目录，你进行修改文件的区域。
**暂存区**，git从库里面有个.git的隐藏目录，里面"有一块"，可以理解为**暂存区**。

<!-- more -->

工作区和缓存区如何联系起来？通过提交代码行为的步骤流程来解读:
1. 修改代码文件   
2. `git add 修改后的代码文件`   **此刻的行为将该代码文件从工作区添加到了暂存区**
3. `git commit -m 'commit 内容'`  **此刻的行为把暂存区的内容提交到了本地分支上**

最后的`git push`操作只是一个将本地分支推送到远端的行为，所以先不考虑进去，只考前面三点。

查看工作区和暂存区常用的命令为`git status`

一般常见的是如下三种情况：
1. 在工作区**新建**了文件或目录，但还未将这些文件或目录`git add`提交到暂存区。这些文件或目录被标记为**untracked files**。


```shell
huangyisan:~/Desktop/github/test $ touch foo bar
huangyisan:~/Desktop/github/test $ ls
bar foo
huangyisan:~/Desktop/github/test $ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	bar
	foo

nothing added to commit but untracked files present (use "git add" to track)
```

1. 对修改后的文件进行了`git add`操作，将这些文件提交到了暂存区，但未执行`git commit -m 'xxx'`，未提交到本地分支。此时文件属于`Changes to be committed`状态


```shell
huangyisan:~/Desktop/github/test $ git add foo
huangyisan:~/Desktop/github/test $ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	new file:   foo

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	bar

```

1. 对已经`git add`操作，但未提交到本地分支的文件，继续进行了修改，修改完后未进行`git add`，此时文件属于`Changes not staged for commit`状态
```
huangyisan:~/Desktop/github/test $ echo 'new line' >> foo
huangyisan:~/Desktop/github/test $ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	new file:   foo

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   foo

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	bar

```

4. 已经commit到本地分支的文件，且该文件在工作区没被修改之前，其不会在git status中出现。

## git checkout -- file

两种情况
1. 若被checkout的文件在暂存区，但工作区修改了，也就是上面的**第三种**情况，此时执行该命令，被checkout的文件变成和暂存区一样的状态和内容。
```
huangyisan:~/Desktop/github/test $ echo 'first line' > foo
huangyisan:~/Desktop/github/test $ git add foo
huangyisan:~/Desktop/github/test $ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   foo

huangyisan:~/Desktop/github/test $ cat foo
first line

huangyisan:~/Desktop/github/test $ echo 'new line' >> foo
huangyisan:~/Desktop/github/test $ cat foo
first line
new line
huangyisan:~/Desktop/github/test $ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   foo

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   foo
huangyisan:~/Desktop/github/test $ git checkout -- foo
huangyisan:~/Desktop/github/test $ cat foo
first line
```
将foo文件写入'first line'内容后，用`git add foo`，提交到了暂存区，未commit情况下，再写入新内容'new line',若想还原到暂存区状态，则使用命令`git checkout -- foo`

2. 被修改文件不在暂存区，此时使用`git checkout -- file`命令，则该文件和当前版本仓库中原先的文件一致。
```
huangyisan:~/Desktop/github/test $ git status
On branch master
nothing to commit, working tree clean
huangyisan:~/Desktop/github/test $ cat foo
first line
huangyisan:~/Desktop/github/test $ echo 'new line' >> foo
huangyisan:~/Desktop/github/test $ cat foo
first line
new line
huangyisan:~/Desktop/github/test $ git checkout -- foo
huangyisan:~/Desktop/github/test $ cat foo
first line
```
干净的工作区，修改了foo文件，然后进行checkout操作之后，foo文件还原成了仓库中该文件原先的状态和内容。

## git clean

git clean 的对象为**untracked files**，也就是在工作区**新建**，但还未执行``git add``命令提交到暂存区的文件或目录。
```
huangyisan:~/Desktop/github/test $ ls
bar foo
huangyisan:~/Desktop/github/test $ touch new1 new2
huangyisan:~/Desktop/github/test $ mkdir {tmp1,tmp2}
huangyisan:~/Desktop/github/test $ ls
bar  foo  new1 new2 tmp1 tmp2
huangyisan:~/Desktop/github/test $ git clean -n
Would remove new1
Would remove new2
huangyisan:~/Desktop/github/test $ git clean -f new1
Removing new1
huangyisan:~/Desktop/github/test $ git clean -df tmp1
Removing tmp1/
huangyisan:~/Desktop/github/test $ ls
bar  foo  new2 tmp2
huangyisan:~/Desktop/github/test $ git clean -f
Removing new2
huangyisan:~/Desktop/github/test $ ls
bar  foo  tmp2
huangyisan:~/Desktop/github/test $ git clean -df
Removing tmp2/
huangyisan:~/Desktop/github/test $ ls
bar foo
```

`git clean -n`，干跑模式，可以列出哪些文件会被清除，但不会列出哪些目录会被清除。
`git clean -f`，若指定文件，则该文件被清除，若不指定文件，则所有未被提交到暂存区的文件都被清除。
`git clean -df`，若指定目录，则该目录被清除，若不指定目录，则所有未被提交到暂存区的目录都被清除。

## git rm

`git rm`等价于`rm xxx && git add .`。
如果一个文件是被rm删除，则可以使用`git checkout -- file`将文件还原回来，而如果是用`git rm`删除，则该文件不可以被`git checkout -- file`。当然，如果是rm文件，然后git add操作，也是不能被`git checkout -- file`还原回来的。
```
huangyisan:~/Desktop/github/test $ ls
bar foo
huangyisan:~/Desktop/github/test $ rm foo
remove foo? y
huangyisan:~/Desktop/github/test $ ls
bar
huangyisan:~/Desktop/github/test $ git checkout foo
huangyisan:~/Desktop/github/test $ ls
bar foo
huangyisan:~/Desktop/github/test $ git rm foo
rm 'foo'
huangyisan:~/Desktop/github/test $ git checkout foo
error: pathspec 'foo' did not match any file(s) known to git.
huangyisan:~/Desktop/github/test $ ls
bar
```

foo文件起先被rm删除，并未提交到暂存区，所以是可以被checkout还原，后来执行了git rm，所以当使用checkout还原的时候就报错了。


## git reset

三种模式
1. --mixed 默认方式，将暂存区内容清空，回退到工作区，并且保留工作区的修改内容。

```
huangyisan:~/Desktop/github/test $ cat foo
first line
huangyisan:~/Desktop/github/test $ echo 'new line' >> foo
huangyisan:~/Desktop/github/test $ git add foo
huangyisan:~/Desktop/github/test $ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   foo

huangyisan:~/Desktop/github/test $ cat foo
first line
new line
huangyisan:~/Desktop/github/test $ git reset HEAD
Unstaged changes after reset:
M	foo
huangyisan:~/Desktop/github/test $ cat foo
first line
new line
huangyisan:~/Desktop/github/test $ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   foo

no changes added to commit (use "git add" and/or "git commit -a")
```
暂存区被清空，工作区的更变被保留下来，foo文件存在new line这行内容。

2. --soft  暂存区内容，工作区内容都被保留，HEAD指向指定的commit号，该commit号原先的文件若有变动，则直接被add到暂存区。

```
huangyisan:~/Desktop/github/test $ ls
foo
huangyisan:~/Desktop/github/test $ cat foo
huangyisan:~/Desktop/github/test $ echo 'new line' > foo
huangyisan:~/Desktop/github/test $ git add foo
huangyisan:~/Desktop/github/test $ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   foo

huangyisan:~/Desktop/github/test $ git log --oneline
e5ca64a (HEAD -> master) 1
0ba0aa5 1
ebaa828 1
a2f32c5 1
8f89d40 update
be60bed 1
bb51c34 .
df8f824 update
4dbd952 update
9e683fb 1
79dfad8 1
3e58cef add 1
94e5bf4 remove
02aadbb ok
huangyisan:~/Desktop/github/test $ git reset --soft 8f89d40
huangyisan:~/Desktop/github/test $ ls
foo
huangyisan:~/Desktop/github/test $ cat foo
new line
huangyisan:~/Desktop/github/test $ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	deleted:    bar
	new file:   foo

```

将foo的改动add到暂存区后，使用`git reset --soft 8f89d40`，8f89d40这个commit号原先是存在bar这个文件，且foo文件不存在，因为reset之前的内容和之后的比较出现了差异，则这些差异被add到了新的暂存区中。

3. --hard  HEAD重置到指定commit号，且清空暂存区，工作区的内容和该commit号版本仓库的内容一致。

```
huangyisan:~/Desktop/github/test $ git reset --hard HEAD
HEAD is now at 14d3892 1
huangyisan:~/Desktop/github/test $ ls
foo
huangyisan:~/Desktop/github/test $ cat foo
first line
```

暂存区被清空，工作区内容成了当前commit号版本仓库的内容，也就是没修改之前的内容，foo文件不存在new line行。
**但若工作区存在Untracked files，则这些Untracked files会携带进入到指定的commit号版本仓库的工作区中，所以要恢复到和某个commit号完全一致，还需要git clean -f清空Untracked files。**


**git reset会将HEAD指向的分支指向reset对应的commit，而git checkout是HEAD直接指向对应的commit。**
![](http://ww1.sinaimg.cn/large/9f0d15f3gy1fyiqk5xn2gj20dw0a6aa3.jpg)


## git revert

仅将某个commit号提交分支的内容撤销，且将此次撤销作为一个新的提交。

```
huangyisan:~/Desktop/github/test $ git log --oneline
145af31 (HEAD -> master) add new
edf54e3 add foo
c11842d add bar
5f4b280 remove all
huangyisan:~/Desktop/github/test $ ls
bar  foo  new  new1
huangyisan:~/Desktop/github/test $ git revert c11842d
[master 19e736c] Revert "add bar"
 1 file changed, 0 insertions(+), 0 deletions(-)
 delete mode 100644 bar
huangyisan:~/Desktop/github/test $ ls
foo  new  new1
huangyisan:~/Desktop/github/test $ git log --oneline
19e736c (HEAD -> master) Revert "add bar"
145af31 add new
edf54e3 add foo
c11842d add bar
5f4b280 remove all
```

c11842d是将bar文件提交到了分支，当执行`git revert c11842d`,则撤销了提交bar文件到分支，所以执行完后，bar文件不见了，但foo文件依旧存在，所以revert只影响了被撤销的commit的变更内容，而且看git log，多了一个新的commit提交号19e736c。
