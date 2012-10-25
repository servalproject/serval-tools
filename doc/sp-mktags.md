sp-mktags
=========

Generates **tags** and **cscope.out** index files in the root directory of the
current Git repository.  These indices make navigating C and Java source code
very easy in Vim and other editors that support ctags and cscope.  For more
information:

    sp-mktags --help

If the **`--all`** option is given, then sp-mktags finds the current outermost
enclosing Git repository, and generates *tags* and *cscope.out* files in its
root directory and the root directories of all its submodules.

If the `ndk-build` executable is found in the current `$PATH` and if a
`project.properties` file is found in an enclosing directory and it contains a
`target=` line, then sp-mktags includes the header files of the configured
target Android NDK API in the *tags* and *cscope.out* files of any repository
that contains at least one C header or source file.

The following script in your personal bin directory will work regardless of
whether your current working directory is within a Serval Git repository:

    #!/bin/sh
    cd $HOME/path/to/my/serval/batphone/repository || exit $?
    exec sp-mktags --all
