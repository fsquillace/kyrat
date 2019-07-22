kyrat
=====
Kyrat - An ssh wrapper script that brings your dotfiles always with you on Linux and OSX

|Project Status|Communication|
|:-----------:|:-----------:|
|[![Build status](https://api.travis-ci.org/fsquillace/kyrat.png?branch=master)](https://travis-ci.org/fsquillace/kyrat) | [![Join the gitter chat at https://gitter.im/fsquillace/kyrat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fsquillace/kyrat?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) |

**Table of Contents**
- [Description](#description)
- [Quickstart](#quickstart)
- [Comparison with sshrc](#comparison-with-sshrc)
- [Installation](#installation)
  - [Dependencies](#dependencies)
  - [Linux](#linux)
  - [OSX](#osx)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Authors](#authors)
- [Last words](#last-words)

Description
===========
kyrat is a ssh wrapper that allows to source local dotfiles
on a ssh session to a remote host. It works either from/to a Linux or OSX machine.

*kyrat* transfers the content of a **bash** user-defined module
(located in either `~/.config/kyrat/bashrc` or in the directory `~/.config/kyrat/bashrc.d/`)
to the remote host and open a bash session by sourcing the transferred modules.

Similarly, *kyrat* can transfer **inputrc** files (located
in either `~/.config/kyrat/inputrc` or
inside the directory `~/.config/kyrat/inputrc.d/`)
and **vimrc** files (located in either `~/.config/kyrat/vimrc` or inside
the directory `~/.config/kyrat/vimrc.d/`).

Quickstart
==========
### Bash ###
Write locally in either `~/.config/kyrat/bashrc` or any files inside `~/.config/kyrat/bashrc.d/`:

    alias q=exit

    function processof(){
        ps -U $1 -u $1 u
    }

    export PATH=$PATH:/sbin:/usr/sbin


Now, just access to your remote host:

    $> kyrat myuser@myserver.com
    myserver.com $> processof feel
        feel     20567  0.3  0.0  14748   952 pts/5    S+   12:44   0:13 ping www.google.com
        feel     23458  0.0  0.0  12872  1372 pts/9    R+   13:49   0:00 ps -U feel -u feel u

    myserver.com $> q
    exit

Or even inline:

    $> kyrat myuser@myserver.com -- processorof feel

### Vim ###
Write locally in either `~/.config/kyrat/vimrc` or any files inside `~/.config/kyrat/vimrc.d/`:

    nnoremap <silent> <Leader>e :Explore<CR>

Now, just access to your remote host via `kyrat`, run vim and you will have the shortcut `\e` for running the vim file explorer.

### Inputrc ###
Write locally in either `~/.config/kyrat/inputrc` or any files inside `~/.config/kyrat/inputrc.d/`:

    set completion-ignore-case On

Now, just access to your remote host via `kyrat` and the terminal will have case insensitive tab completion.

### Tmux ###
Write locally in either `~/.config/kyrat/tmux.conf` or any files inside `~/.config/kyrat/tmux.conf.d/`:

    bind e setw synchronize-panes on \; display "Synchronization ON"
    bind E setw synchronize-panes off \; display "Synchronization OFF"

Now, just access to your remote host via `kyrat` and run the following:

```bash
tmux -f "$TMUX_CONF"
```

This will open a tmux session and you can now toggle synchronization between
panes on the same window with the keys `e/E`.

Comparison with sshrc
=====================
[sshrc](https://github.com/Russell91/sshrc) is a program that performs a similar task as Kyrat.
Despite its popularity, at the time of writing, there are significant drawbacks on using sshrc.

The following table shows the comparison between Kyrat and sshrc:

|  | Dotfile types supported | Platform  | Unit tests | Integration tests | Compression | Portability | Default remote shells | Automatic removal of the remote dotfiles | Remote dotfiles location |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Kyrat** | `bash`, `vim`, `inputrc` | Linux, OSX | **YES** | **YES** | **YES** | Small number of `coreutils` executables required | **ANY** | **YES** | `/tmp` and fallback to `$HOME` |
| **sshrc** | `bash` (the rest requires additional work) | Unknown | **NO** | **NO** | **YES** | Big number of executables required (`tar`, `awk`, `openssl`, and more) | `bash` only | **YES** | `/tmp` only |

Installation
============
Dependencies
------------
Before installing Kyrat be sure that all dependencies are properly installed in your system.
The Kyrat dependencies are the following:

- [bash (>=4.0)](https://www.gnu.org/software/bash/)
- [GNU coreutils](https://www.gnu.org/software/coreutils/)

Linux
-----
Assuming all Kyrat dependencies are properly installed in the system, to install Kyrat
run the following:
```sh
    git clone https://github.com/fsquillace/kyrat ~/.local/share/kyrat
    export PATH=$PATH:~/.local/share/kyrat/bin
```

OSX
---
In order to install all Kyrat dependencies, you first need to install [Homebrew](http://brew.sh/).

To install all the needed dependencies via Homebrew:
```sh
brew update
brew install coreutils
```

Once all Kyrat dependencies are properly installed in the system, to install Kyrat
run the following:
```sh
    git clone https://github.com/fsquillace/kyrat ~/.local/share/kyrat
    export PATH=$PATH:~/.local/share/kyrat/bin
```

Troubleshooting
===============
This section has been left blank intentionally.
It will be filled up as soon as troubles come in!

Contributing
============
You could help improving Kyrat in the following ways:

- [Reporting Bugs](CONTRIBUTING.md#reporting-bugs)
- [Suggesting Enhancements](CONTRIBUTING.md#suggesting-enhancements)
- [Writing Code](CONTRIBUTING.md#your-first-code-contribution)

Authors
=======
- Filippo Squillace <feel.sqoox@gmail.com>.

Last words
==========
    Consider your origins:
    You were not born to live like brutes
    but to follow virtue and knowledge.
    [verse, Dante Alighieri, from Divine Comedy]
