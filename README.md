serval-tools
============

Various tools that the Serval Project uses to develop its software.

Shell utilities
---------------

To use these utilities, check out the **serval-tools** repository somewhere
(eg, into /usr/local/serval-tools) and add its *bin* directory to your path,
eg, by putting the following line into your shell's $HOME/.profile:

    export PATH="$PATH:/usr/local/serval-tools/bin"

None of these utilities make any assumptions about your layout of Serval source
code Git repositories.  They all act on the current directory and the current
Git repository as determined by the current working directory.

### `sp-ls-files`

A wrapper around **git ls-files** that handles submodules intelligently.  For
more information:

    sp-ls-files --help

All options not recognised by sp-ls-files itself are passed verbatim to *git
ls-files*.  If no such options are given, then sp-ls-files invokes *git
ls-files* with the options `--exclude-standard --cached --other`, which lists
all files that are not ignored, including files that are not being tracked by
Git (ie, are pending *git add*.)

All pathnames output by sp-ls-files are relative to the caller's current
working directory.

The options recognised by sp-ls-files are:

*  **`-S`** or **`--submodules`**
   Cause sp-ls-files to list all files in the current outermost enclosing Git
   repository, including in all submodules of that repository.  For example, if
   you are inside the batphone/jni/serval-dna submodule, `sp-ls-files -S` will
   list all files in the `batphone` repository and all of its submodules,
   including jni/serval-dna itself.

*  **`--no-submodules`** (the default)
   Causes sp-ls-files to treat its arguments as path names of files or
   directories, and invokes *git ls-files* on each argument in turn after
   changing directory to the root of the Git repository containing the path.
   This allows you to list files within submodules of the current repository,
   which *git ls-files* does not support.

   If no arguments are given, then sp-ls-files behaves just like *git ls-files*
   with no arguments, ie, lists the files in the current (innermost) Git
   repository.

### `sp-find`

A wrapper around the standard *find*(1) utility that excludes files ignored by
the current outermost enclosing Git repository and all its submodules.

This is very convenient for performing project-wide searches without searching
intermediate build files.  It was originally developed to stop sp-grep from
matching twice in the serval-dna repository, which concatenates all of its C
header and source files into `serval.c` while building.

sp-find invokes *sp-ls-files --submodules* to discover all the files that Git
ignores.

_Known issue_: sp-find does not deal with path names that contain spaces,
either on the command line or in the output from *sp-ls-files*.

### `sp-grep`

Searches all files in the current outermost enclosing Git repository for a
given pattern, analogous to the **find -type f | xargs grep** idiom, except
that it uses *sp-ls-files --submodules* instead of *find*(1).  All arguments
are passed directly to the `grep` command.  For more information:

    sp-grep --help

sp-grep recognises the following special options that it does not pass through
to *grep*:

*  **`--java`**  Only search in files ending in `.java`
*  **`--xml`**   Only search in files ending in `.xml`
*  **`--c`**     Only search in files ending in `.h` or `.c`

These options are cumulative, eg, giving `--java --xml` will search in all Java
and XML files.

A convenient wrapper script makes invoking sp-grep even easier.  Place the
following script called **`jgrep`** in your personal bin directory:

    #!/bin/sh
    cd $HOME/path/to/my/serval/batphone/repository || exit $?
    exec sp-grep --java "$@"

Then you can type `jgrep string` to find all occurrences of `string` in all
Java source files in the Serval source code.

### `sp-mktags`

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

### `sp-exclude-directories`

A simple filter that removes all lines that name an existing directory.  This
is used by *sp-grep* to ensure that it does not invoke *grep*(1) on directories.

Vim Git plugin
--------------

The *gitdiff.vim* plugin for the *vim*(1) editor provides easy access to
the Git commit history of any file being edited and easy shortcuts for opening
diff windows to reveal changes.

To use the plugin, check out the **serval-tools** repository somewhere (eg,
into /usr/local/serval-tools) and add its *vim* directory to your Vim runtime
path, eg, by putting the following line into your $HOME/.vimrc:

    set runtimepath=~/.vim,/usr/local/serval-tools/vim,$VIMRUNTIME,/usr/local/serval-tools/vim/after,~/.vim/after

The [plugin file](vim/plugin/gitdiff.vim) itself contains a block comment at
the top describing the keymappings that it provides.  The author plans to
create a Vim help file for the plugin soon.
