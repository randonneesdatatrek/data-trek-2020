# Intro to Git and GitHub
### PoisotLab - 2020-III-13

[This guide](https://github.com/kguidonimartins/studygroup-ufg/blob/master/guia-de-referencia.md#trabalhando-com-branches) covers command line basics.

### Motivation
### Structure of git flow
*!* We won't talk about conflicts! There is good documentation about it online, and much of the learning is done by practicing. We suggest you create a repo to play with your teammates!

### Configuring your system  
```
git config --global user.name "yourname"
git config --global user.email "yourname@yourmail.com"
git config --list #Confirm
```  

**Store your credentials to clone using https**  
```
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
```

### Start a new repo  
1. Create repo on github
2. Clone to local
> `git clone`
3. Initiate local repo
> `git init`
4. Link remote and local
> `git remote add origin url`

### Daily workflow
1. Check your status
> `git status`
2. Add files to track
> `git add`
3. Store your changes
> `git commit`
3.1 Check what has been commited
> `git log`
> `git log file`
> `git log --oneline`
4. Check if the remote branch has modifications conflicts with your local
> `git fetch origin`
5. Push your modifications to remote
> `git push`
6. Check if the remote branch has modifications conflicts with your local again
> `git fetch origin`
7. Update your local with remote modifications
> `git pull`
8. Inspect differences
> `git diff`

### Working with branches
1. Show branches
> `git branch -a`
> `git branch name`
> `git checkout`

2. Merge updates from master remote to local branch
```
git checkout master
git pull
git checkout seu-branch
git merge master seu-branch
git push
```
3. Reverting commits
> `git revert <commit hash>`


### Good practices on PRs and Issues
- make smaller and frequent PRs
- tag the related issue so it closes automatically once you solved the problem (PR approved)
- Take some time to write useful descriptions
- Be precise on commit messages (descriptive, but short)

#### Issues
- Same tips for PRs
- Use tags, milestones, projects!
- Tag people to delegate
- Tag related branches
- Tag related code
- If it's a bug, provide reproducible examples and system especifications

