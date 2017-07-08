AIT

Android Imaging Tools

This tool kit provides a set of functions to facilitate a software build
process for Android devices.  Specific actions include downloading various (but
not arbitrary) images, installing them to the device, doing the same for
certain apps, such as superuser, setting the device to certain states, such as
recovery mode, and performing backup/restore operations.

The primary use case is updating a rooted stock image.  If you don't have root,
over the air (OTA) updates are more convenient.  If you have a non-stock image,
I expect it to have an automatic update system.

Personally, I like to stay with mostly stock software when possible, but I want
root access, and I also want updates.  I found the process of deploying a stock
image, then reapplying the recovery image, then rooting again, to be a bit
tedious, so I have attempted to automate that process with the script
**upgrade\_device**.  (Now I have two problems; updating my phone is tedious, and
I spend twice as much time debugging this script every time I update my phone.
NO RAGRETS)


Files:

  - upgrade\_device - Script to upgrade a device.  Specify a profile name.

  - lib/ - Libraries.

  - platforms/ - Per-device-model configuration files.

  - profiles/ - Per-individual-device configuration files.
