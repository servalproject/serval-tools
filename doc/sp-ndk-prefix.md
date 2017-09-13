sp-ndk-prefix
=============

Detects whether a given path is within an Android project, and if so, prints
the prefix of the NDK development files (headers and libraries) for the
project's configured target ABI level.  It detects the ABI level for projects
built using Gradle (app/build.gradle) and using Ant (project.properties).

If no Android project is found, or there is no NDK package for the configured
ABI, then returns a non-zero exit status, otherwise prints the path prefix and
returns a zero exit status.

Example:

    $ sp-ndk-prefix ~/source/batphone/app/src
    /home/username/installed/android-ndk-r13b/platforms/android-9
    $

For more information:

    sp-ndk-prefix --help
