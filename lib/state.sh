#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.


function reboot_device {
  state="$(get_state)" \
    || fail             "Failed to get state."
  case "${state}" in
    'device')
      adb reboot \
        || fail         "Failed to reboot device."
      wait_for_android
      ;;
    'sideload')
      adb sideload /dev/null
      sleep 5
      ;&
    'recovery')
      ;&
    'bootloader')
      boot_device \
        || fail         "Failed to reboot device."
      ;;
    *)
      fail              "Unknown state:  ${state}"
      ;;
  esac
}


function boot_device {
  state="$(get_state)" \
    || fail             "Failed to get state."
  case "${state}" in
    'device')
      output            "Device is already booted."
      ;;
    'sideload')
      adb sideload /dev/null
      sleep 5
      ;&
    'recovery')
      adb reboot \
        || fail         "Failed to reboot device."
      wait_for_android
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
  state="$(get_state)" \
    || fail             "Failed to get state."
  case "${state}" in
    'sideload')
      adb sideload /dev/null
      sleep 5
      ;&
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
        wait_for_android
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


function boot_recovery_image {
  state="$(get_state)" \
    || fail             "Failed to get state."
  case "${state}" in
    'sideload')
      adb sideload /dev/null
      sleep 5
      ;&
    'recovery')
      ;&
    'device')
      output            "Rebooting device from device to fastboot."
      boot_fastboot \
        || fail         "Failed to boot fastboot."
      ;&
    'bootloader')
      output            "Rebooting device from fastboot to recovery."
      fastboot boot "${1}" \
        || fail         "Failed to boot recovery image."
      wait_for_recovery
      ;;
    *)
      fail              "Unknown device state:  '${state}'"
      ;;
  esac
}


function reboot_fastboot {
  state="$(get_state)" \
    || fail             "Failed to get state."
  if test "${state}" == 'fastboot'; then
    fastboot reboot-fastboot \
      || fail           "Failed to reboot fastboot."
  else
    boot_fastboot \
      || fail           "Failed to reboot fatboot."
  fi
}


function boot_fastboot {
  state="$(get_state)" \
    || fail             "Failed to get state."
  case "${state}" in
    'sideload')
      adb sideload /dev/null
      sleep 5
      ;&
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
    ! test "${adb_count}" -ge 1
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
    ! test "${adb_count}" -ge 1
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
    ! test "${fastboot_count}" -ge 1
  do
    output      "Device not yet detected."
    sleep 1
  done
  output        "fastboot is up."
}


function device_id {
  adb devices | awk '/\tdevice|recovery/ {print $1}'
  fastboot devices | awk '/\tfastboot/ {print $1}'
}


function count_android_devices {
  echo $(( $(adb devices | wc -l) - 2 ))
}


function count_fastboot_devices {
  echo $(fastboot devices | wc -l)
}


function get_state {
  while true; do
    if test 1 -le $(count_android_devices); then
      adb get-state
      break
    elif test 1 -le $(count_fastboot_devices); then
      echo bootloader
      break
    else
      prompt "Device is missing.  Jiggle the cables or something.  Try again or quit?  [T,q]"
      case $response in
        'Q')
          ;&
        'q')
          fail "Device missing."
          ;;
        *)
          ;;
      esac
    fi
  done
}

