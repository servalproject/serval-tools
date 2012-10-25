sp-ls-files
===========

A wrapper around **git ls-files** that handles submodules intelligently.  For
more information:

    sp-ls-files --help

All options not recognised by sp-ls-files itself are passed verbatim to *git
ls-files*.  If no such options are given, then sp-ls-files invokes *git
ls-files* with the options `--exclude-standard --cached --other`, which lists
all files that are not ignored, including files that are not being tracked by
Git (ie, are pending *git add*.)

All pathnames output by sp-ls-files are relative to the caller’s current
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


