pearl-ssh
=========
pearl-ssh - Pearl module ssh wrapper to bring your config files always with you

Description
===========
pearl-ssh is a ssh wrapper (uses the same syntax) and allow to (magically)
transfer your favourite aliases, functions and variables to a remote host.

*ssh_pearl* transfers the content of a bash user-defined module
(in `~/.config/pearl/sshrc` or in the directory `~/.config/pearl/sshrc.d/`)
to the remote host and open a bash session based on the transferred modules.

It is even possible to transfer an inputrc file located
in `~/.config/pearl/sshinputrc` or inside the directory `~/.config/pearl/sshinputrc.d/`.


## Quickstart ##

Write in either `~/.config/pearl/sshrc` or any files inside `~/.config/pearl/sshrc.d/`:

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

Installation
============

### Method one ###
Just clone the repository:

    $ git clone https://github.com/fsquillace/pearl-ssh ~/.pearl-ssh

Then, write in your own `~/.bashrc` or execute in terminal the following:

    $ source ~/.pearl-ssh/lib/ssh_pearl.sh

## Method two ##
`pearl-ssh` is a module for the [*pearl framework*](https://github.com/fsquillace/pearl).
After installing `pearl` you can easily install `pearl-ssh` with the following command:

    $ pearl module install pearl/ssh

Furthermore, if you want to include the `pearl` utility aliases and functions
inside pearl-ssh, just install the proper package:

    $ pearl module install pearl/utils

This means that some of the `pearl` modules will be transfered automatically
(aliases.sh, ops.sh, ...).

If you want to use the handy `pearl` inputrc, enable it in the `pearl` dotfiles module:

    $ pearl module install pearl/dotfiles
    $ pearl-dotfiles enable inputrc

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
Filippo Squillace <feel.squally@gmail.com>.

## WWW ##
https://github.com/fsquillace/pearl
https://github.com/fsquillace/pearl-ssh

## Last words ##

    Consider your origins:
    You were not born to live like brutes
    but to follow virtue and knowledge.
    [verse, Dante Alighieri, from Divine Comedy]

