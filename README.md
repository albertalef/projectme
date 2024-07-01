# Project Me

A simple way to enter in your projects folders from anywhere

![](demo.gif)

Instalation
------------
### Requirements
- [fzf](https://github.com/junegunn/fzf)

### MacOs or Linux
```sh
curl -sSL https://raw.githubusercontent.com/albertalef/projectme/master/install.sh | sh
```

Configuration
------------
Change your project folder in your shell config file
```sh
export PROJECTS_DIR='$HOME/path-to-folder'
```
After edit the shell config file, restart your terminal or execute `source ~/.bashrc` or `source ~/.zshrc`.

Create the projects dir folder:
```sh
mkdir "$PROJECTS_DIR"
```

And just use it!

### Windows
> [!WARNING]
> Comming...
