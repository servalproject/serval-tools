sp-openwrt-release
==================

This [Bash][] script automates the task of updating a [Serval Project][]
[OpenWRT package][] within the [Serval OpenWRT feed][] to refer to a newer
revision of its underlying Git repository.  This effectively amounts to
releasing a newer version of the package for OpenWRT.

For command-line usage information, see the script's built-in help:

    $ sp-openwrt-release --help
    ...
    $

**sp-openwrt-release** is designed for use by experienced Serval developers
with an understanding of [Git][], the [OpenWRT build system][] and [GNU
make][].  Unless the `--quiet` option is given, it prints a log of all
significant commands that it invokes, so that any failure can be interpreted in
the context that it occurred.

Set the feed repository clone
-----------------------------

If you have a local clone of the [Serval OpenWRT feed][] repository, and want
the **sp-openwrt-release** script to use it instead of creating a temporary
clone, then set the following environment variable (this can be done in a [Bash
startup file][] like `$HOME/.profile` so that the setting is permanent):

    $ export SERVAL_OPENWRT_PACKAGES_REPO="$HOME/src/openwrt-packages"
    $

This can be useful if, for example, you wish to inspect the results of the
script and possibly modify them before committing and pushing to GitHub, or you
have already committed other changes to the feed repository that you wish to
push in a single operation.

Example
-------

TODO

More information
----------------

 * the [OpenWRT build instructions for Serval DNA][] give an introduction to
   the OpenWRT build system and contain instructions for making OpenWRT
   releases of [Serval DNA][]

 * the [Serval OpenWRT feed][] README describes the OpenWRT release procedure
   in detail

 * the [Serval Mesh release procedure][] describes the release procedure for
   the [Serval Mesh][] app for Android


[Serval Project]: http://www.servalproject.org
[Serval OpenWRT feed]: https://github.com/servalproject/openwrt-packages
[Serval DNA]: https://github.com/servalproject/serval-dna
[Batphone]: https://github.com/servalproject/batphone
[Serval Mesh release procedure]: http://developer.servalproject.org/dokuwiki/doku.php?id=content:servalmesh:release:
[OpenWRT build instructions for Serval DNA]: https://github.com/servalproject/serval-dna/blob/development/doc/OpenWRT.md
[OpenWRT package]: http://wiki.openwrt.org/doc/devel/packages
[Bash]: http://en.wikipedia.org/wiki/Bash_(Unix_shell)
[Bash startup file]: http://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
[topic branch]: http://git-scm.com/book/en/Git-Branching-Branching-Workflows
[Git]: http://git-scm.com/
[OpenWRT build system]: http://wiki.openwrt.org/about/toolchain
[GNU make]: http://www.gnu.org/software/make/
