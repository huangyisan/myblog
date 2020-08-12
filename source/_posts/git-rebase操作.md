---
title: git rebase操作
date: 2019-03-26 17:12:00
tags: [linux,git]
---

## 同一分支 不同文件 无冲突情况

1. 本地修改master，远端(模拟其他协同开发人员)修改remote_change

```
$ ls
master  remote_change

```

2. 查看当前git log信息

```
huangyisan@huangyisan-PC MINGW64 ~/Desktop/github/pingan/testgit (master)
$  git log --graph --pretty=oneline --abbrev-commit
* aed5259 (HEAD -> master, origin/master) local change 2
* d327114 local change 1

```

当前分支指向master，且和远程对齐。

3. 非本地进行提交
比如使用web页面gitlab提交，模拟协同操作仓库，修改remote_change内容

4. 然后本地进行提交
修改master文件内容两次，并且commit，进行push

```
$ git commit -m 'local change 3'
[master d327114] local change 3
 1 file changed, 1 insertion(+), 1 deletion(-)

 $ git commit -m 'local change 4'
[master aed5259] local change 4
 1 file changed, 1 insertion(+), 1 deletion(-)

```


进行push，此时因为非本地端已经被提交，当前仓库不是最新代码，push被rejected，查看git log内容

```
$  git log --graph --pretty=oneline --abbrev-commit
* 8dd9d20 (HEAD -> master) local change 4
* f6b8c95 local change 3
* aed5259 (origin/master) local change 2
* d327114 local change 1
* d0e5f73 change local 17
```
当前位置比远程仓库快2个位置。由于远程已经有提交内容，本地仓库不是最新代码，需要git pull.


5. 仓库重新pull，并查看git log

```
$  git log --graph --pretty=oneline --abbrev-commit
*   5b4b59f (HEAD -> master) Merge branch 'master' of http://gitlab.ptest.cdn.pingan.com.cn:19090/huangyisan/testgit
|\
| * 3fb5469 (origin/master) 更新 remote_change 1
* | 8dd9d20 local change 4
* | f6b8c95 local change 3
|/
* aed5259 local change 2
* d327114 local change 1
```

此时出现了'分叉'，本地指向的是和远程merge的内容，但远程是指向3fb5469位置，还没更新本地的两个commit提交内容。


6. 使用rebase，查看git log

```
$ git rebase
First, rewinding head to replay your work on top of it...
Applying: local change 3
Applying: local change 4
```

查看git log

```
$  git log --graph --pretty=oneline --abbrev-commit
* c10a76b (HEAD -> master) local change 4
* 4101717 local change 3
* 3fb5469 (origin/master) 更新 remote_change 1
* aed5259 local change 2
* d327114 local change 1

```

**此时git log变成了一条直线。查看git log内容更加清晰明了。**
本地指向c10a76b 远端仓库指向3fb5469，还需要对本地进行git push

7. git push提交更变内容
由于只是rebase，并没有git push，所以还需要把本地的量词修改提交到远端仓库

```
$ git push
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 4 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (6/6), 569 bytes | 569.00 KiB/s, done.
Total 6 (delta 0), reused 0 (delta 0)
To http://xxxxxxxxxxxxxxxxxxxxxxx
   3fb5469..c10a76b  master -> master

```

## 同一分支 相同文件 有冲突情况

1. 查看git log信息

```
$  git log --graph --pretty=oneline --abbrev-commit
* d01191c (HEAD -> master, origin/master) local change 1
* 6b113ef remove
```

2. 本地和远端都修改master文件，让其产生冲突

本地:

```
$ cat master
local change 2
```

远端:

```
local change 1
remote change 2
```

3. 远端提交，然后本地也push

本地不是指向最新的commit，本地需要先pull

4. 本地pull操作，出现了冲突

git status内容

```
$ git status
On branch master
Your branch and 'origin/master' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" to merge the remote branch into yours)

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)

        both modified:   master

no changes added to commit (use "git add" and/or "git commit -a")

```

冲突内容

```
$ cat master
<<<<<<< HEAD
local change 2
=======
local change 1
remote change 2
>>>>>>> 2497b92a10abea64a2cfc7072039bbf497cc11e0

```

5. add commit冲突内容

**此时如果修改冲突内容然后rebase，则修改的内容又会还原，所以先add commit**

```
$ git commit -m 'conficlit'
[master a252b15] conficlit
```

查看git log，发现出现分叉了

```
$  git log --graph --pretty=oneline --abbrev-commit
*   a252b15 (HEAD -> master) conficlit
|\
| * 2497b92 (origin/master) 更新 master
* | 92bf8fc local change 2
|/

```

6. 此时进行git rebase操作
查看git log 之前的分叉没了

```
$  git log --graph --pretty=oneline --abbrev-commit
* 2497b92 (HEAD, origin/master) 更新 master
* d01191c local change 1
* 6b113ef remove
*   f6e9fe8 update

```

7. 然后修复冲突，并且进行add

修复冲突后 add，**但不commit**

```
$ git add master
```

8. 进行git rebase --continue操作

```
$ git rebase --continue
Applying: local change 2
```

查看git log, 此时本地HEAD比远端快，所以需要push

```
$  git log --graph --pretty=oneline --abbrev-commit
* 455b381 (HEAD -> master) local change 2
* 2497b92 (origin/master) 更新 master
* d01191c local change 1
```

9. 最后进行git push

查看git log 测试及本地HEAD和远端对齐commit号了

```
$  git log --graph --pretty=oneline --abbrev-commit
* 455b381 (HEAD -> master, origin/master) local change 2
* 2497b92 更新 master
* d01191c local change 1
* 6b113ef remove
*   f6e9fe8 update
```

## 不同分支 无冲突情况

1. dog cat两个基于master checkout出来的分支，当前git log出现分叉

![](http://ww1.sinaimg.cn/large/9f0d15f3ly1g1hsqriytzj20gn068wes.jpg)


2. 在cat分支上进行git rebase dog

```
$ git rebase dog
First, rewinding head to replay your work on top of it...
Applying: cat
Applying: cat
```

3. 查看git log ，cat和dog的分叉合并了
![](http://ww1.sinaimg.cn/large/9f0d15f3ly1g1hsp6ghkfj20fz08hgm5.jpg)

## 不同分支 有冲突情况

1. dog cat两个基于master checkout出来的分支，当前git log出现分叉

![](http://ww1.sinaimg.cn/large/9f0d15f3ly1g1ht0t2p82j20hv08wjrx.jpg)

2. 在cat分支上进行git rebase dog 出现了冲突

```
$ git rebase dog
First, rewinding head to replay your work on top of it...
Applying: cat
Applying: cat
Applying: remove cat dog
Using index info to reconstruct a base tree...
A       dog
Falling back to patching base and 3-way merge...
Removing cat
Applying: cat
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
Auto-merging annimal
CONFLICT (add/add): Merge conflict in annimal
error: Failed to merge in the changes.
hint: Use 'git am --show-current-patch' to see the failed patch
Patch failed at 0004 cat

Resolve all conflicts manually, mark them as resolved with
"git add/rm <conflicted_files>", then run "git rebase --continue".
You can instead skip this commit: run "git rebase --skip".
To abort and get back to the state before "git rebase", run "git rebase --abort".
```

3. 解决冲突后，git add ，然后`git rebase --continue` 无需git commit

```
$ git add annimal

$ git rebase --continue
Applying: cat

```

4. 查看git log已经解决分叉情况

![](http://ww1.sinaimg.cn/large/9f0d15f3ly1g1ht138yvwj20g807pq3b.jpg)

## 结论
1. **只对**`尚未推送`**或分享给别人的本地修改执行变基操作清理历史**
2. **从不对已推送至别处的提交执行变基操作**
3. 如果存在冲突，则解决完冲突后，进行git add，之后不需要git commit，直接使用`git rebase --continue`
4. rebase目的就是让协同开发同事看log更加清晰明了。

refer
> https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/0015266568413773c73cdc8b4ab4f9aa9be10ef3078be3f000#0
> http://gitbook.liuhui998.com/4_2.html
> https://www.youtube.com/watch?v=HeF7dwVyzow&feature=player_embedded
