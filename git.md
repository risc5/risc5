* Clone github issues

https://gissue.github.io/

很多东西不用都忘记了，比如
git rebase

git remote -v

> origin  https://github.com/YOUR_USERNAME/YOUR_FORK.git (fetch)
 
> origin  https://github.com/YOUR_USERNAME/YOUR_FORK.git (push)

Specify a new remote upstream repository that will be synced with the fork.


$ git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git

git fetch upstream

# checkout to local master branch
git checkout master

git merge upstream/master


ref:
https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork
