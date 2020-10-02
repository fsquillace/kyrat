kyrat
=====
Kyrat - A simple ssh wrapper script that brings your dotfiles always with you on Linux and OSX

|Project Status|Communication|
|:-----------:|:-----------:|
|[![Build status](https://api.travis-ci.org/fsquillace/kyrat.png?branch=master)](https://travis-ci.org/fsquillace/kyrat) | [![Join the gitter chat at https://gitter.im/fsquillace/kyrat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fsquillace/kyrat?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) |

**Table of Contents**
- [Description](#description)
- [Quickstart](#quickstart)
- [Installation](#installation)
  - [Dependencies](#dependencies)
  - [Linux](#linux)
  - [OSX](#osx)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Donating](#donating)
- [Authors](#authors)
- [Last words](#last-words)

Description
===========
kyrat is a ssh wrapper that allows to source local dotfiles
on a ssh session to a remote host.
No installations or root access on the remote host are required.
It works either from/to a Linux or OSX machines.

*kyrat* can transfer to the remote host and source the following dotfiles:

- **bashrc** files (located in either `~/.config/kyrat/bashrc` or inside the directory `~/.config/kyrat/bashrc.d/`).
- **inputrc** files (located in either `~/.config/kyrat/inputrc` or inside the directory `~/.config/kyrat/inputrc.d/`)
- **vimrc** files (located in either `~/.config/kyrat/vimrc` or inside the directory `~/.config/kyrat/vimrc.d/`).
- **tmux.conf** files (located in either `~/.config/kyrat/tmux.conf` or inside the directory `~/.config/kyrat/tmux.conf.d/`).
- **zshrc** files (located in either `~/.config/kyrat/zshrc` or inside the directory `~/.config/kyrat/zshrc.d/`).


### Environment variables

- `KYRAT_SHELL` can be used to set which shell to spawn remotely (default is `bash`). The allowed shells are `bash`, `zsh` and `sh`.
- `KYRAT_TMPDIR` remote location to store the dotfiles (default `/tmp`).


### Kyrat features
The following summarizes the Kyrat features:

- Dotfile types supported: `bashrc`, `vimrc`, `inputrc`, `tmux.conf`, `zshrc`
- Platform: Linux, OSX
- Compression during tranfer: `gzip`
- Encoding during transfer: `base64`
- Automatic removal of remote dotfiles when exiting from Kyrat session
- Remote dotfile location: `/tmp` (configurable via `KYRAT_TMPDIR` env variable)
- Remote shells available to spawn: `bash`, `zsh` or `sh` (configurable via `KYRAT_SHELL` env variable)

### How it works?

This is the sequence of steps that occur when running Kyrat:

- The dotfiles are encoded using Base64 and compressed with Gzip
- The dotfile blobs are passed through the ssh command line containing a script
- The remote host will execute such script with the instructions of:
  - how to decode and extract the dotfiles
  - where to store the dotfiles (according to `KYRAT_TMPDIR` variable)
  - which environment variables to set to make the dotfiles working properly
  - which remote shell to spawn (`bash`, `zsh` or `sh` according to `KYRAT_SHELL` variable)

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
brew install bash coreutils
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

Donating
========
To sustain the project please consider funding by donations through
the [GitHub Sponsors page](https://github.com/sponsors/fsquillace/).

Authors
=======
Kyrat was originally created in April 2014 by [Filippo Squillace (feel.sqoox@gmail.com)](https://github.com/fsquillace).

Here is a list of [**really appreciated contributors**](https://github.com/fsquillace/kyrat/graphs/contributors)!

[![](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/images/0)](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/links/0)[![](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/images/1)](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/links/1)[![](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/images/2)](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/links/2)[![](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/images/3)](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/links/3)[![](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/images/4)](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/links/4)[![](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/images/5)](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/links/5)[![](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/images/6)](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/links/6)[![](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/images/7)](https://sourcerer.io/fame/fsquillace/fsquillace/kyrat/links/7)

Last words
==========
    Consider your origins:
    You were not born to live like brutes
    but to follow virtue and knowledge.
    [verse, Dante Alighieri, from Divine Comedy]
