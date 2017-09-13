sp-mktags
=========

Generates **tags** and **cscope.out** index files in the root directory of the
Git repository containing the given path (default current working directory).
These indices make navigating C and Java source code very easy in Vim and other
editors that support ctags and cscope.  For more information:

    sp-mktags --help

If the **`--all`** option is given, then sp-mktags finds the outermost
enclosing Git repository, and generates *tags* and *cscope.out* files in its
root directory and in the root directories of all its submodules.

In each Git repository, `sp-mktags` invokes the [sp-ndk-prefix](./sp-ndk-prefix.md)
utility to detect whether the repo is a submodule of an Android project, and
if so, includes all the NDK header files for the project's target ABI in the
generated tags.

The following script in your personal bin directory will work regardless of
whether your current working directory is within a Serval Git repository:

    #!/bin/sh
    cd $HOME/path/to/my/serval/batphone/repository || exit $?
    exec sp-mktags --all
