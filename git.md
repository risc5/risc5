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
