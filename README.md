AIT
Android Imaging Tools

This is a set of functions and scripts intended to facilitate ad hoc deployment
of various types of images for Android devices (system image, recovery image,
etc), as well development of complete upgrade paths for specific devices.

Stock devices are probably better served by OTA updates, and a reputable
after-market image will come with its own update routines.  The envisioned use
case for these tools is devices running stock firmware which has been modified,
for example rooted, so that OTA updates will no longer work.

If you want to play with the functions:

  source ait


Files:

  - ait - This is a library of functions.  This is the big blob of code sourced
    by smaller scripts.

  - device.conf - Device specific settings.

  - upgrade\_nexus - Script for upgrading a Nexus device, tested with Nexus 5.
