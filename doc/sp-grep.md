sp-grep
=======

Searches all files in the current outermost enclosing Git repository for a
given pattern, analogous to the **find -type f | xargs grep** idiom, except
that it uses *sp-git-ls-all-files --submodules* instead of *find*(1).  All
arguments are passed directly to the `grep` command.  For more information:

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
