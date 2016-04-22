kyrat
=====
Kyrat - An ssh wrapper script that brings your dotfiles always with you

[![Build status](https://api.travis-ci.org/fsquillace/kyrat.png?branch=master)](https://travis-ci.org/fsquillace/kyrat)
[![Join the gitter chat at https://gitter.im/fsquillace/kyrat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fsquillace/kyrat?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Description
===========
kyrat is a ssh wrapper that allows to source local dotfiles
on a ssh session in a remote host.

*kyrat* transfers the content of a **bash** user-defined module
(located in either `~/.config/kyrat/bash` or in the directory `~/.config/kyrat/bashrc.d/`)
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


Installation
============

### Method one ###
Just clone the repository:

    git clone https://github.com/fsquillace/kyrat ~/.local/share/kyrat

Then, either write in your own `~/.bashrc` or execute in terminal the following:

    export PATH=$PATH:~/.local/share/kyrat/bin

## Copyright ##

    Copyright  (C) 2008-2016 Free  Software Foundation, Inc.

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
Of course there is no bug in kyrat, but there may be unexpected behaviors.
Go to 'https://github.com/fsquillace/kyrat/issues' you can report directly
this unexpected behaviors.

## Authors ##
Filippo Squillace <feel.sqoox@gmail.com>.

## WWW ##

- https://github.com/fsquillace/kyrat

## Last words ##

    Consider your origins:
    You were not born to live like brutes
    but to follow virtue and knowledge.
    [verse, Dante Alighieri, from Divine Comedy]

