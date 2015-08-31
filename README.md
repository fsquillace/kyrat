pearl-ssh
=========

[![Join the chat at https://gitter.im/fsquillace/pearl-ssh](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fsquillace/pearl-ssh?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
pearl-ssh - An ssh wrapper script that brings your dotfiles always with you

Description
===========
pearl-ssh is a ssh wrapper that allows to source local dotfiles
on a ssh session in a remote host.

*ssh_pearl* transfers the content of a **bash** user-defined module
(located in either `~/.config/pearl/sshrc` or in the directory `~/.config/pearl/sshrc.d/`)
to the remote host and open a bash session by sourcing the transferred modules.

Similarly, *ssh_pearl* can transfer **inputrc** files (located
in either `~/.config/pearl/sshinputrc` or
inside the directory `~/.config/pearl/sshinputrc.d/`)
and **vimrc** files (located in either `~/.config/pearl/sshvimrc` or inside
the directory `~/.config/pearl/sshvimrc.d/`).


Quickstart
==========

### Bash ###
Write locally in either `~/.config/pearl/sshrc` or any files inside `~/.config/pearl/sshrc.d/`:

    alias q=exit

    function processof(){
        ps -U $1 -u $1 u
    }

    export PATH=$PATH:/sbin:/usr/sbin


Now, just access to your remote host:

    $> ssh_pearl myuser@myserver.com
    myserver.com $> processof feel
        feel     20567  0.3  0.0  14748   952 pts/5    S+   12:44   0:13 ping www.google.com
        feel     23458  0.0  0.0  12872  1372 pts/9    R+   13:49   0:00 ps -U feel -u feel u

    myserver.com $> q
    exit

### Vim ###
Write locally in either `~/.config/pearl/sshvimrc` or any files inside `~/.config/pearl/sshvimrc.d/`:

    nnoremap <silent> <Leader>e :Explore<CR>

Now, just access to your remote host via `ssh_pearl`, run vim and you will have the shortcut `\e` for running the vim file explorer.

### Inputrc ###
Write locally in either `~/.config/pearl/sshinputrc` or any files inside `~/.config/pearl/sshinputrc.d/`:

    set completion-ignore-case On

Now, just access to your remote host via `ssh_pearl` and the terminal will have case insensitive tab completion.


Installation
============

### Method one ###
Just clone the repository:

    git clone https://github.com/fsquillace/pearl-ssh ~/.pearl-ssh

Then, either write in your own `~/.bashrc` or execute in terminal the following:

    source ~/.pearl-ssh/lib/ssh_pearl.sh

## Method two ##
`pearl-ssh` can be even installed as a module from the [*pearl framework*](https://github.com/fsquillace/pearl).
After installing `pearl` you can easily install `pearl-ssh` with the following command:

    pearl module install pearl/ssh

Furthermore, if you want to include the `pearl` utility aliases and functions
inside pearl-ssh, just install the proper package:

    pearl module install pearl/utils

This means that some of the `pearl` modules will be transfered automatically
(aliases.sh, ops.sh, ...).

Also, If you want to use the handy `pearl` inputrc and vimrc, enable them in the `pearl` dotfiles module:

    pearl module install pearl/dotfiles
    pearl-dotfiles enable inputrc
    pearl-dotfiles enable vimrc

## Help ##
If you have installed `pearl-ssh` as a module for the [*pearl framework*](https://github.com/fsquillace/pearl), you can use the manual anytime typing the following command:

    man pearl.ssh

## Copyright ##

    Copyright  (C) 2008-2015 Free  Software Foundation, Inc.

    Permission  is  granted to make and distribute verbatim copies
    of this document provided the copyright notice and  this  per‐
    mission notice are preserved on all copies.

    Permission is granted to copy and distribute modified versions
    of this document under the conditions  for  verbatim  copying,
    provided that the entire resulting derived work is distributed
    under the terms of a permission notice identical to this one.

    Permission is granted to copy and distribute  translations  of
    this  document  into  another language, under the above condi‐
    tions for  modified  versions,  except  that  this  permission
    notice  may  be  stated  in a translation approved by the Free
    Software Foundation.

## Bugs ##
Of course there is no bug in pearl. But there may be unexpected behaviors.
Go to 'https://github.com/fsquillace/pearl-ssh/issues' you can report directly
this unexpected behaviors.

## Authors ##
Filippo Squillace <feel.sqoox@gmail.com>.

## WWW ##

- https://github.com/fsquillace/pearl
- https://github.com/fsquillace/pearl-ssh

## Last words ##

    Consider your origins:
    You were not born to live like brutes
    but to follow virtue and knowledge.
    [verse, Dante Alighieri, from Divine Comedy]

