* Clone github issues

# use ssh
git clone git@github.com:Mohism-Research/chia-docs.git 

https://gissue.github.io/

很多东西不用都忘记了，比如
git rebase

git remote -v

> origin  https://github.com/YOUR_USERNAME/YOUR_FORK.git (fetch)

> origin  https://github.com/YOUR_USERNAME/YOUR_FORK.git (push)

Specify a new remote upstream repository that will be synced with the fork.


$ git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git

git fetch upstream

#checkout to local master branch

git checkout master

git merge upstream/master

#commit and setup one branch

git push origin new_branch

> remote: Create a pull request for 'jello_cpu' on GitHub by visiting:
> 
> remote:      https://github.com/filecoin-performance/venus-docs/pull/new/jello_cpu



* Git diff say "no newline at end of file"
git add -p 

ref:
https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork



* how to show chinese

```shell
git status

git config --global core.quotepath false

[core]
 12         quotepath = false
```



### fatal: early EOF fatal: index-pack failed




873

First, turn off compression:

git config --global core.compression 0
Next, let's do a partial clone to truncate the amount of info coming down:

git clone --depth 1 <repo_URI>
When that works, go into the new directory and retrieve the rest of the clone:

git fetch --unshallow 
or, alternately,

git fetch --depth=2147483647
Now, do a regular pull:

git pull --all







### git submodule

当一个项目很大很复杂时，可以将项目分为几个模块分别进行管理；或者，当一个项目引用第三方开源代码，可以将这些第三方开源代码单独进行管理，这样做是为了代码隔离，方便项目维护。这时可以使用git的submodule功能，git submodule允许你将一个 git 仓库作为另一个 git 仓库的子目录。

git submodule用于多模块（仓库）管理，其父项目与子项目提交是分开的，父项目提交只包含子项目的信息，而不会包括子项目的代码，子项目使用独立的commit、push、pull操作。

**简单来说：**父项目git仓库管理父项目内容和子项目信息；子项目git仓库管理子项目内容。



另一个有用的场景是：当项目依赖并跟踪一个开源的第三方库时，将第三方库设置为submodule。





包含子项目的repo，运行，这个是第一次



```bash
$ git clone --recursive <project url>
```

或者这个可以是后面的补充方式

~~~
git submodule add    # 添加子模块

git submodule init   # 只用执行一次，后续同步只需执行git submodule update
git submodule update # 更新子模块

git diff --cached --submodule

~~~





* 拉取所有子项目

  

  ~~~
   git pull --recurse-submodules
  ~~~

  或者

  ~~~
  
  git submodule foreach git checkout master
  git submodule foreach git pull
  ~~~

  

* 更新 **所有** 子模块



`git submodule update --remote` 时，Git 默认会尝试更新 **所有** 子模块







