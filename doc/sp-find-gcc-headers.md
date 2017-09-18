sp-find-gcc-headers
===================

Prints all the header files that are included by a given GCC command line, by
interpreting the GCC options that add directories to the include search path,
such as `-I`, `--isystem`, etc.

This is useful in Makefiles, for example to provide a `tags` target that
indexes all the non-standard header files that are actually used for
compilation.

For more information:

    sp-find-gcc-headers --help

