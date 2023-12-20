# WorkingScripts

Scripts used for work and Study

Everything you see is used for work, so it is kept in a sloppy arrangement. More power to you if it helps you.

https://24.17.229.82:8006/
## LINUX

Space for Linux studies.

Use the package manager [pip](https://pip.pypa.io/en/stable/) to install foobar.

```bash

sudo apt-get update
sudo apt full-upgrade -y

git clone https://github.com/sandervanvugt/bash-scripting

```

## GIT

```Git

Space for GIT
git push
git add .
git commit
git pull
git checkout <branch>
git branch
git branch -d <name of branch> = deletes
git branch -a = more info on branches
git pull -r = git pull rebase
git log
git fetch
git rebase
git rm -r --cached restfuller
git stash
git stash pop
git status
git reset --hard HEAD~1
git reset HEAD~1 =essentially removes commit but leaves files
git commit amend = add to existing commit
git push --force = used after a hard git reset <risky>
git revert <commit hash>
git merge master
git merge --squash <feature>
git log --graph --oneline --decorate
git bisect start | bad  | good
git checkout -

## Able to abort for immediate issues
git merge --abort
git rebase --abort

Notes
Good content.  However, I think you missed one of the more common patterns involving rebase and merge.  In your case of an LT branchA and work branchB with changes on both you rebased the changes in branchA on the changes in branchB.   In my experience, it is more common to rebase the changes in branchB on the changes in branchA (checkout branchB, rebase branchA, <resolve conflicts, build, test>, commit) then merge the resolved changes back into branchA (checkout branchA, merge branchB).  That final merge MUST be a fast-forward.  If it isn't, start over.  This completely avoids the problem of rewriting history on branchA that you alluded to.  Given branchA may be used as a base by other developers and could be hosted on a server that disallows history changes, that is essential.

Notes
Also even if you like to rebase an already pushed branch, you could do it safety using the "git push --force-with-lease" and the "git pull --rebase" options, that will avoid you overwritten any changes made in the remote branch.

```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)