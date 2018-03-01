# dotfiles

## Setup

This repo uses a rather hacky approach to managing dotfiles without using ugly link files or other complex scripts. It works by creating a git repository inside the home folder and restrict everything except your dotfiles via a `.gitignore` file.

### Creating a new repo

**Initialize a new git repository**
```bash
$ cd ~
$ git init
$ git remote add origin <repo url>
```

**Add a .gitignore and copy dotfile.sh to home directory**

Content of `.gitignore`:

```
*
!.gitignore
!dotfile.sh
```

**Use script to add/remove dotfiles**

- Adding: `$ ./dotfile.sh -a .vimrc`
- Removing: `$ ./dotfile.sh -d .vimrc`

Publish using `git push`. Done!
