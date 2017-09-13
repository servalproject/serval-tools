sp-find
=======

A wrapper around the standard *find*(1) utility that excludes files ignored by
the current outermost enclosing Git repository and all its submodules.

This is very convenient for performing project-wide searches without searching
intermediate build files.  It was originally developed to stop sp-grep from
matching twice in the serval-dna repository, which concatenates all of its C
header and source files into `serval.c` while building.

sp-find invokes *sp-git-ls-all-files --submodules* to discover all the files
that Git ignores.

_Known issue_: sp-find does not deal with path names that contain spaces,
either on the command line or in the output from *sp-git-ls-all-files*.
