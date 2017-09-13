sp-git-ls-all-files
===================

A wrapper around **git ls-files** that handles submodules intelligently.  For
more information:

    sp-git-ls-all-files --help

All options not recognised by sp-git-ls-all-files itself are passed verbatim to
*git ls-files*.  If no such options are given, then sp-git-ls-all-files invokes
*git ls-files* with no options, which lists all files being tracked by Git.
For example, to also include files that are not being tracked by Git (ie, are
pending *git add*) but are ignored by Git:

    sp-git-ls-all-files --cached --other --exclude-standard

All pathnames output by sp-git-ls-all-files are relative to the caller’s
current working directory.

The options recognised by sp-git-ls-all-files are:

*  **`-S`** or **`--submodules`**
   List all files in the outermost enclosing Git repository of the given path,
   including in all submodules of that repository.  For example,
   `sp-git-ls-all-files -S ~/src/batphone/jni/serval-dna` will list all files
   in the `batphone` repository and all of its submodules, including
   `jni/serval-dna` itself.

*  **`--no-submodules`** (the default)
   List all files in innermost enclosing Git repository of the given path.

If no **path** argument is given, then sp-git-ls-all-files uses the current
directory as the given path.
