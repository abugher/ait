AIT

Android Imaging Tools

This is to facilitate deployment of stock images to Android devices.
"Deployment" includes applying a recovery image, installing a superuser
application, backup and restore of user data, etc.

The primary use case is a rooted stock image.  Over-the-air updates are more
convenient, if running without root.  A good after-market image should come
with its own self-update system, so you don't need to bother with my buggy
scripts.

Personally, I like to stay with mostly stock software when possible, but I want
root access, and I also want updates.  I found the process of deploying a stock
image, then reapplying the recovery image, then rooting again, to be a bit
tedious, so I have attempted to automate that process with the script
"update\_device".


Files:

  - lib - Libraries.  (A shell script that just defines functions is a library,
    right?  Sure.)

  - platforms - Configuration files for specific device models.  (A shell
    script that just sets variables is a configuration file, right?  Yeah,
    totally.)

  - profiles - Configuration files for individual devices, typically named for
    the user.

  - upgrade\_device - Script for upgrading a device.
