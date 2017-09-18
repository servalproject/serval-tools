serval-tools
============
[Serval Project][], September 2017

Tools that the [Serval Project][] uses to develop its software.

All unit documentation is in the [doc](doc/) folder.  See below for
installation instructions.

Command-line utilities
----------------------

To use these utilities, check out the **serval-tools** repository somewhere
(eg, into /usr/local/serval-tools) and add its *bin* directory to your path,
eg, by putting the following line into your shell's $HOME/.profile:

    export PATH="$PATH:/usr/local/serval-tools/bin"

The following utilities are aimed at making it easier to work with Git and Git
submodules.  They make no assumptions about the layout of source code Git
repositories.  They all act on the current directory and the current Git
repository as determined by the current working directory.

* [sp-git-ls-all-files](doc/sp-git-ls-all-files.md) is a wrapper around **git
  ls-files** that lists all the Git-tracked files in a repo, and optionally in
  its submodules and in the repo(s) of which it is itself a submodule

* [sp-find](doc/sp-find.md) is a wrapper around the standard *find*(1) utility
  which excludes files that are ignored by Git

* [sp-grep](doc/sp-grep.md) performs a *grep*(1) over all the files returned
  by *sp-git-ls-all-files*

* [sp-mktags](doc/sp-mktags.md) generates **tags** and **cscope.out** index
  files for the current Git working copy

* [sp-ndk-prefix](doc/sp-ndk-prefix.md) prints the path prefix of the NDK
  development files, if any, for the configured ABI target of the Android
  project containing a given path

* [sp-find-gcc-headers](doc/sp-find-gcc-headers.md) prints the paths of all the
  header files that are included by a given GCC command line

* [sp-exclude-directories](doc/sp-exclude-directories.md) is a simple filter
  that removes all lines that name a directory

The following utilities are used to automate various Serval Project processes,
such as testing, releasing, etc.:

* [sp-openwrt-release](doc/sp-openwrt-release.md) releases new versions of
  Serval Project repositories that are already available as OpenWRT packages,
  by updating the package's Makefile in the [Serval OpenWRT feed][]

The following utility is a general-purpose script for migrating issues from a
Mantis bug tracker to the GitHub Issues list of any GitHub repository:

* [sp-mantis2github](doc/sp-mantis2github.md)

Vim Git plugin
--------------

The *gitdiff.vim* plugin for the *vim*(1) editor has been superseded by the
[delta.vim](https://github.com/quixotique/vim-delta) plugin.

Linux.conf.au 2013
------------------

The [lca-2013](./lca-2013) directory contains scripts and configuration file
samples used to set up the Serval telephony server at Linux.conf.au 2013 held
in Canberra from January 28 to February 5.


[Serval Project]: http://www.servalproject.org
[Serval OpenWRT feed]: https://github.com/servalproject/openwrt-packages
