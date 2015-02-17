Builds intellij idea images.

Creates a basic installation by downloading and running the installer:

    spoon build ideaIC-14.0.3.me

Modifies the install - configure this Spoonscript to your liking:

    spoon build ideaIC-cfg-14.0.3.me

Run the image:

    spoon try -d --mount=%userprofile%\.ivy2 --mount=%userprofile%\.IdeaIC14 jdk64:7,ideaIC-cfg:14.0.3

This sets up a java 64bit development environment and mounts the user's ivy2 and IdeaIC14 folders so that settings and cache can be preserved.
