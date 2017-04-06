#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.


function reboot_device {
  if test $(get_state) == 'device'; then
    adb reboot \
      || fail           "Failed to reboot device."
    wait_for_android
  else
    boot_device \
      || fail           "Failed to reboot device."
  fi
}


function boot_device {
  case "$(get_state)" in
    'recovery')
      adb reboot \
        || fail         "Failed to reboot device."
      wait_for_android
      ;;
    'device')
      output            "Device is already booted."
      ;;
    'bootloader')
      fastboot reboot \
        || fail         "Failed to reboot from fastboot to android."
      wait_for_android
      ;;
    *)
      fail              "Unknown device state:  '${state}'"
      ;;
  esac
}


function boot_recovery {
  case "$(get_state)" in
    'recovery')
      output            "Device is already in recovery mode."
      ;;
    'device')
      output            "Rebooting device from android to recovery."
      adb reboot recovery \
        || fail         "Failed to reboot from android to recovery."
      wait_for_recovery
      ;;
    'bootloader')
      if test 'direct' = "${1}"; then
        prompt          "Use the volume and power buttons to enter Recovery, then press enter."
        wait_for_recovery
      else
        output          "Rebooting device from fastboot to android."
        fastboot reboot \
          || fail       "Failed to reboot from fastboot to android."
        wait_for_recovery
        output          "Rebooting device from android to recovery."
        adb reboot recovery \
          || fail       "Failed to reboot from android to recovery."
        wait_for_recovery
      fi
      ;;
    *)
      fail              "Unknown device state:  '${state}'"
      ;;
  esac
}


function reboot_fastboot {
  if test $(get_state) == 'fastboot'; then
    fastboot reboot-fastboot \
      || fail           "Failed to reboot fastboot."
  else
    boot_fastboot \
      || fail           "Failed to reboot fatboot."
  fi
}


function boot_fastboot {
  case "$(get_state)" in
    'recovery')
      adb reboot-bootloader \
        || fail         "Failed to reboot from fastboot to fastboot."
      wait_for_fastboot
      ;;
    'device')
      adb reboot-bootloader \
        || fail         "Failed to reboot from android to fastboot."
      wait_for_fastboot
      ;;
    'bootloader')
      output            "Device is already in fastboot mode."
      ;;
    *)
      fail              "Unknown device state:  '${state}'"
      ;;
  esac
}
 

function wait_for_android {
  output        "If your device is encrypted, unlock it."
  output        "Waiting for adb..."
  while 
    adb_count=$(count_android_devices)
    ! test "${adb_count}" -eq 1
  do
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


function wait_for_recovery {
  output        "If your device is encrypted, unlock it."
  output        "Waiting for recovery..."
  while 
    adb_count=$(count_android_devices)
    ! test "${adb_count}" -eq 1
  do
    output      "Device not yet detected."
    sleep 1
  done
  output "recovery is up."
}


function wait_for_fastboot {
  output        "Waiting for fastboot..."
  while 
    fastboot_count=$(count_fastboot_devices)
    ! test "${fastboot_count}" -eq 1
  do
    output      "Device not yet detected."
    sleep 1
  done
  output        "fastboot is up."
}


function count_android_devices {
  echo $(( $(adb devices | wc -l) - 2 ))
}


function count_fastboot_devices {
  echo $(fastboot devices | wc -l)
}


function get_state {
  while true; do
    if test 1 == $(count_android_devices); then
      adb get-state
      break
    elif test 1 == $(count_fastboot_devices); then
      echo bootloader
      break
    else
      prompt            "Device is missing.  Jiggle the cables or something.  Try again or quit?  [T,q]"
      case $response in
        'Q')
          ;&
        'q')
          fail          "Device missing."
          ;;
        *)
          ;;
      esac
    fi
  done
}

