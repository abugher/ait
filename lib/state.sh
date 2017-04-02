#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.


function reboot_from_device_to_device {
  output        "Rebooting device from android to android."
  adb reboot \
    || fail     "Failed to reboot from android to android."
  wait_for_adb
}


function reboot_from_fastboot_to_device {
  output        "Rebooting device from fastboot to android."
  fastboot reboot \
    || fail     "Failed to reboot from fastboot to android."
  wait_for_adb
}


function boot_device {
  state="$(get_state)"
  case "${state}" in
    'recovery')
      reboot_from_recovery_to_device \
        || fail         "Failed to reboot from recovery to android."
      ;;
    'device')
      # device == android
      output            "Device is already booted."
      ;;
    'unknown')
      # unknown == bootloader, aka fastboot
      reboot_from_fastboot_to_device \
        || fail         "Failed to reboot from fastboot to android."
      ;;
    *)
      fail              "Unknown device state:  '${state}'"
      ;;
  esac
}


function reboot_from_device_to_fastboot {
  output        "Rebooting device from android to fastboot."
  adb reboot-bootloader \
    || fail     "Failed to reboot from android to fastboot."
  wait_for_fastboot
}


function reboot_from_fastboot_to_fastboot {
  output        "Rebooting device from fastboot to fastboot."
  fastboot reboot-bootloader \
    || fail     "Failed to reboot from fastboot to fastboot."
  wait_for_fastboot
}


function cycle_adb {
  output        "Killing adb."
  adb kill-server \
    || fail     "Failed to kill adb server."
  output        "Starting adb."
  adb start-server \
    || fail     "Failed to start adb server."
}


function enter_recovery {
  state="$(get_state)"
  case "${state}" in
    'recovery')
      output            "Device is already in recovery mode."
      ;;
    'device')
      output            "Rebooting device from android to recovery."
      adb reboot recovery \
        || fail         "Failed to reboot from android to recovery."
      prompt            "Do not modify the system volume.  When recovery is loaded, hit Enter."
      ;;
    'bootloader')
      if test 'direct' = "${1}"; then
        prompt          "Use the volume and power buttons to enter Recovery, then press enter."
        output          "If using systemless superuser, do not allow modifications to the system partition."
        prompt          "Unlock if necessary, and press Enter when Recovery has loaded."
      else
        output          "Rebooting device from fastboot to android."
        fastboot reboot \
          || fail       "Failed to reboot from fastboot to android."
        wait_for_adb
        output          "Rebooting device from android to recovery."
        adb reboot recovery \
          || fail       "Failed to reboot from android to recovery."
        prompt          "Do not modify the system volume.  When recovery is loaded, hit Enter."
      fi
      ;;
    *)
      fail              "Unknown device state:  '${state}'"
      ;;
  esac
}


function enter_fastboot {
  if test 0 -eq $(count_fastboot_devices); then
    output      "Rebooting from android to fastboot."
    reboot_from_device_to_fastboot \
      || fail   "Failed to reboot from android to fastboot."
  fi
}
 

function wait_for_adb {
  output        "If your device is encrypted, unlock it."
  output        "Waiting for adb..."
  # This doesn't work at the end...
  while 
    adb_count=$(count_adb_devices)
    ! test "${adb_count}" -eq 1
  do
    #output "... ${adb_count} / 1 devices detected."
    sleep 1
  done

  
  while 
    boot_completed=$(
      adb shell getprop sys.boot_completed \
        2>/dev/null \
        | sed 's/[^0-9]//g'
    )
    ! test "${boot_completed}" = '1'
  do
    sleep 1
  done

  output "adb is up."
}


function wait_for_fastboot {
  output        "Waiting for fastboot..."
  fastboot_count=$(count_fastboot_devices)
  while ! test "${fastboot_count}" -eq 1; do
    output      "Device not yet detected."
    sleep 1;
    fastboot_count=$(count_fastboot_devices)
  done
  output        "fastboot is up."
}


function count_adb_devices {
  echo $(( $(adb devices | wc -l) - 2 ))
}


function count_fastboot_devices {
  echo $(fastboot devices | wc -l)
}


function get_state {
  if test 1 == $(count_adb_devices); then
    adb get-state
  elif test 1 == $(count_fastboot_devices); then
    echo bootloader
  else
    echo unkown
  fi
}

