AIT

Android Imaging Tools

This is a deployment provisioning toolkit for Android devices.  You can do at
least these things with it:
  - Automatically download software.
    - *Non-trivial to implement for current stock Android download site.  (User
      interaction currently required.)*
  - Install images and apps.
  - Change states as gracefully as possible.
    - *android (__adb__), bootloader (__fastboot__), and recovery (more __adb__...) modes.*
    - *Currently getting from fastboot to recovery takes significant user interaction.*
    - *Booting to recovery from an image could work from fastboot.  __fastboot boot twrp.img__*
  - Backup and restore.
    - *__adb backup__ and __adb restore__*
    - *File format is weird, and hard to extract.*
    - *Backup and recovery work consistently, lately.*

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

  - ait - The thing itself, in executable form.  Usage:
    
      ait <profile> <module> [module arguments]

      Example:  ait aaron upgrade

  - modules/ - High level routines.  Right now there's one called "upgrade",
    and that's pretty much it.

  - lib/ - Libraries.  The functions used by the relatively short module
    scripts are defined here.

  - platforms/ - Per-device-model configuration files.

  - profiles/ - Per-individual-device configuration files.  Unique device ID,
    and personal preferences, if any.

To Do:

  - Cascade error messages well.

  - Unit tests.

  - Download files only when necessary.

  - Make functions more distinct units.  (Unit tests will help.)
