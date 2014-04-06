pearl-ssh
=========

## Name ##
pearl-ssh - Pearl module ssh wrappers

## Description ##
pearl-ssh contains two main bash functions *ssh_pearl* and *ssh_mini_pearl*.
They are both ssh wrappers that use the same ssh syntax and allow to transfer your favourite
aliases, functions and variables to a remote host.

*ssh_mini_pearl* transfers the content of a bash user-defined module
(`~/.config/pearl/pearlsshrc`) to the remote host and open a bash session
using the transfered module.
Furthermore, if it is installed as module for
[*pearl framework*](https://github.com/fsquillace/pearl),
some of the `pearl` modules will be transfered automatically
(aliases.sh, options.sh, ops.sh, history.sh, ...).

*ssh_pearl* is able to install/update the
[*pearl framework*](https://github.com/fsquillace/pearl) from the remote host.
It can do it by either `git` or `wget` depending if the `git` command
is installed in the remote host.

## Installation ##

### Option 1 (Recommended) ###
`pearl-ssh` can be a module for the [*pearl framework*](https://github.com/fsquillace/pearl).
After installing `pearl` you can easily install `pearl-ssh` with the following command:

    $ pearl_module_install_update pearl-ssh

### Option 2 ###
`pearl-ssh` can be used alone. Just type:

    $ cd ~
    $ git clone https://github.com/fsquillace/pearl-ssh .pearl-ssh

Then, write in your own `~/.bashrc` or execute in terminal the following:

    $ source ~/.pearl-ssh/lib/ssh.sh


## Quickstart ##

Write in `~/.config/pearl/pearlsshrc`:

    alias q=exit

    function processof(){
        ps -U $1 -u $1 u
    }

    export PATH=$PATH:/sbin:/usr/sbin


Now, just access to your remote host:

    $> ssh_mini_pearl myuser@myserver.com
    myserver.com $> processof feel
        feel     20567  0.3  0.0  14748   952 pts/5    S+   12:44   0:13 ping www.google.com
        feel     23458  0.0  0.0  12872  1372 pts/9    R+   13:49   0:00 ps -U feel -u feel u

    myserver.com $> q
    exit

## Help ##
Just type:

    man pearl.ssh

## Copyright ##

    Copyright  (C) 2008-2014 Free  Software Foundation, Inc.

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
Filippo Squillace <feel.squally@gmail.com>.

## WWW ##
https://github.com/fsquillace/pearl
https://github.com/fsquillace/pearl-ssh

## Last words ##

    Consider your origins:
    You were not born to live like brutes
    but to follow virtue and knowledge.
    [verse, Dante Alighieri, from Divine Comedy]

