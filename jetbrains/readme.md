Builds intellij idea images.

Downloads and installs the base image:

    spoon build ideaIC-14.0.3.me

Modifies the install:

    spoon build ideaIC-cfg-14.0.3.me

Example shortcut:

    spoon try -d --mount=%userprofile%\.ivy2 --mount=%userprofile%\.IdeaIC14 maven-creds,jdk64:7,ideaIC-cfg:14.0.3

Sets up java 64bit development environment and mounts the user's ivy2 and IdeaIC14 profiles so that settings and library cache can be preserved.
