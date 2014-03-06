sp-openwrt-release
==================
[Serval Project], March 2014

This [Bash][] script automates the task of updating a [Serval Project][]
[OpenWRT package][] within the [Serval OpenWRT feed][] to refer to a newer
revision of its underlying Git repository.  This effectively amounts to
releasing a newer version of the package for OpenWRT.

For command-line usage information, see the script's built-in help:

    $ sp-openwrt-release --help
    ...
    $

The [sp-openwrt-release][] script is designed for use by experienced Serval
developers with an understanding of [Git][], the [OpenWRT build system][] and
[GNU make][].  Unless the `--quiet` option is given, it prints all significant
commands as it invokes them, so that any failure can be interpreted in the
context that it occurred.

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

Add a new package
-----------------

[sp-openwrt-release][] does not have any option for adding a new OpenWRT
package.  See the [Serval OpenWRT feed][] README for instructions.

Update an existing package
--------------------------

To release a newer version of an existing package, you must first:

 1. choose which feed branch (denoted `FEEDBRANCH` below) you want to update
    (see the [Serval OpenWRT feed][] README);

 2. [Git clone][] the Serval repository which the package builds (an existing
    clone will serve, as [sp-openwrt-release][] does not modify it); the path
    to this clone's root directory is denoted `REPOPATH` below;

 3. ensure that the clone has its GitHub origin as one of its [Git remotes][];

 4. choose the [Git revision][] (denoted `REV` below) which you wish to
    release;

 5. ensure the revision has been [pushed][Git push] to GitHub.

The [sp-openwrt-release][] script does NOT support specifying a package by name
or Makefile path, because if more than one package builds from the same source
repository, they must all be updated at once, to avoid inconsistencies.

To perform the release, issue the command:

    $ sp-openwrt-release --push --commit FEEDBRANCH CLONEPATH=REV
    ...
    $

As the logged output will show, this will perform the following operations:

 1. checks that REV names a valid revision that has already been [pushed][Git
    push] to GitHub,

 2. [fetches][Git fetch] the [Serval OpenWRT feed][] repository then [checks
    out][Git checkout] the FEEDBRANCH branch and [fast forwards][Git merge] the
    FEEDBRANCH to its upstream origin's head,

 3. finds all Makefiles in FEEDBRANCH whose URL matches CLONEPATH's GitHub
    origin,

 4. computes the version string of revision REV in CLONEPATH by invoking the
    clone's `version_string.sh` executable if it exists, otherwise uses [Git
    describe][],

 5. edits all the matching Makefiles to set the variables: `PKG_VERSION` to the
    version string, `PKG_SOURCE_VERSION` to the SHA1 identifier of REV (or tag
    name if REV is a tag), and increment `PKG_RELEASE`,

 6. [commits][Git commit] the changes to the matching Makefiles with a suitable
    commit message (this step is only done if the `--commit` option is given),

 7. [pushes][Git push] the changes to GitHub to publish them (this step is only
    done if the `--push` option is given).

Create a new feed branch
------------------------

Not implemented.

More information
----------------

 * the [Serval DNA build instructions for OpenWRT][] give an introduction to
   the OpenWRT build system and contain instructions for making OpenWRT
   releases of [Serval DNA][]

 * the [Serval OpenWRT feed][] README describes the OpenWRT release procedure
   in detail

 * the [Serval Mesh release procedure][] describes the release procedure for
   the [Serval Mesh][] app for Android


[Serval Project]: http://www.servalproject.org
[sp-openwrt-release]: ../bin/sp-openwrt-release
[Serval OpenWRT feed]: https://github.com/servalproject/openwrt-packages
[Serval DNA]: https://github.com/servalproject/serval-dna
[Batphone]: https://github.com/servalproject/batphone
[Serval Mesh release procedure]: http://developer.servalproject.org/dokuwiki/doku.php?id=content:servalmesh:release:
[Serval DNA build instructions for OpenWRT]: https://github.com/servalproject/serval-dna/blob/development/doc/OpenWRT.md
[OpenWRT build system]: http://wiki.openwrt.org/about/toolchain
[OpenWRT package]: http://wiki.openwrt.org/doc/devel/packages
[Bash]: http://en.wikipedia.org/wiki/Bash_(Unix_shell)
[Bash startup file]: http://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
[Git]: http://git-scm.com/
[Git remotes]: http://gitref.org/remotes/
[Git revision]: http://git-scm.com/book/en/Git-Tools-Revision-Selection
[Git clone]: http://git-scm.com/docs/git-clone
[Git fetch]: http://git-scm.com/docs/git-fetch
[Git push]: http://git-scm.com/docs/git-push
[Git checkout]: http://git-scm.com/docs/git-checkout
[Git merge]: http://git-scm.com/docs/git-merge
[Git commit]: http://git-scm.com/docs/git-commit
[GNU make]: http://www.gnu.org/software/make/
