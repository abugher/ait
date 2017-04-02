#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.

# expand_aliases makes aliases work.  It's not set in scripts by default.
shopt -s expand_aliases

start_time="$(date "+%Y-%m-%d_%H:%M:%S")"

backup_file="${backup_dir}/${start_time}.ab"
backup_options="-f '${backup_file}' '-apk -all -nosystem -shared'"
#backup_options="-f '${backup_file}' -all"


function output {
  echo "${output_prefix}${1}"
}


function error_output {
  echo "${output_prefix}ERROR:  ${1}"
}


function prompt {
  # Clear stdin.
  while read -r -t 0; do read -r; done
  read -p "${output_prefix}${1}  " response
}


# 'fail' is an alias, not a function, so that the 'return' statement takes
# effect in the context of the calling function, instead of just returning from
# the 'fail' function. 
alias fail='{ read message; error_output "${message}"; return 1; } <<<'


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


function backup_data {
  if test 0 -eq $(count_adb_devices); then
    reboot_from_fastboot_to_device \
      || fail   "Failed to reboot from fastboot to adb."
  fi

  while true; do
    output      "Running 'adb backup' to this file:  ${backup_file}"
    eval "adb backup ${backup_options}" \
      || fail   "Failed:  adb backup ${backup_options}"
    file_size=$(stat --printf="%s" "${backup_file}") \
      || fail   "Failed to ascertain backup file size."
    if test 0 = "${file_size}"; then
      output    "Warning:  That backup was empty."
      output    "Warning:  Use the phone's back button to quit the backup if still running."
      prompt    "Try again, Quit, or Continue?  [T,q,c]  "
      case "${response}" in
        't')
          continue
          ;;
        'q')
          exit
          ;;
        'c')
          break
          ;;
        *)
          continue
          ;;
      esac
    else
      break
    fi
  done

  output        "Backup successful."
}


function restore_data {
  if test 0 -eq $(count_adb_devices); then
    reboot_from_fastboot_to_device \
      || fail   "Failed to reboot from fastboot to adb."
  fi

  wait_for_adb

  if 
    test "" == "${backup_file}" \
    || ! test -f "${backup_file}"
  then
    backup_file=${backup_dir}/$(ls -1tr "${backup_dir}" | tail -n 1)
    output      "Last known backup:  ${backup_file}"
    prompt      "Restore from this file?  [Y,n]"
    case "${response}" in
      'N')
        ;&
      'n')
        exit
        ;;
      *)
        ;;
    esac
  fi

  while true; do
    output      "Restoring data from:  ${backup_file}"
    adb restore "${backup_file}" \
      || fail   "Failed:  adb restore ${backup_file}"
    output      "Warning:  I can't verify success.  (This is normal.)"
    output      "Warning:  I need your judgement on whether to continue."
    prompt      "Try again, Quit, or Continue?  [t,q,C]  "
    case "${response}" in
      'T')
        ;&
      't')
        continue
        ;;
      'Q')
        ;&
      'q')
        exit
        ;;
      *)
        break
        ;;
    esac
  done
  
  reboot_from_device_to_device \
    || fail     "Failed to reboot from adb to adb."
  output        "Restore successful."
}


function latest_twrp_image_link {
  image_list_url="https://dl.twrp.me/${device_code_name}/"

  wget "${image_list_url}" -O - 2>/dev/null \
  | awk -F '"' '/\/'"${device_code_name}"'\// {print $2}' \
  | head -n 1 \
  | sed 's/\.html$//;s/^/https:\/\/dl.twrp.me/'
}


function download_latest_twrp_image {
  if test -e "${twrp_image_file}"; then
    output      "TWRP image file already exists.  Skipping download."
  else
    output      "TWRP download begins."
    wget --referer "${latest_twrp_image_link}" "${latest_twrp_image_link}"
    output      "TWRP download complete."
  fi
}


function download_magisk {
  if test -e "${magisk_file}"; then
    output      "Magisk file already exists.  Skipping download."
  else
    output      "Downloading Magisk from ${magisk_link} to ${magisk_file} ."
    wget \
    -O "${magisk_file}" \
    "${magisk_link}"
  fi

  download_magisk_app \
    || fail     "Failed to download Magisk app."
}


function download_magisk_app {
  if test -e "${magisk_app_file}"; then
    output      "Magisk app file already exists.  Skipping download."
  else
    output      "Downloading Magisk app from ${magisk_app_link} to ${magisk_app_file} ."
    wget \
    -O "${magisk_app_file}" \
    "${magisk_app_link}"
  fi
}


function download_superuser {
  # The referer hack is for supersu.
  output      "Downloading superuser from ${superuser_link} to ${superuser_file} ."
  wget \
  -O "${superuser_file}" \
  --referer="${superuser_link}" \
  "${superuser_link}"
}


function push_magisk {
  output        "Pushing ${magisk_file} to /sdcard/ ."
  adb push "${magisk_file}" /sdcard/    || \
    fail        "Failed to push ${magisk_file} to /sdcard/ ."
}


function push_superuser {
  output        "Pushing ${superuser_file} to /sdcard/ ."
  adb push "${superuser_file}" /sdcard/ || \
    fail        "Failed to push ${superuser_file} to /sdcard/ ."
}


function cycle_adb {
  output        "Killing adb."
  adb kill-server \
    || fail     "Failed to kill adb server."
  output        "Starting adb."
  adb start-server \
    || fail     "Failed to start adb server."
}


function unpack_image {
  output        "Removing old images."
  rm -rf "${device_code_name}"-* \
    || fail     "Failed to remove:  ${device_code_name}-*"
  output        "Unpacking image."
  listing_before=$(ls -1tr)
  unzip -o "${image_file}" \
    || fail     "Failed to unpack image:  ${image_file}"
  listing_after=$(ls -1tr)
  image_dir=$(echo -e "${listing_before}\n${listing_after}" | sort | uniq -u)
  output        "Image unpacked."
}


function install_image {
  if test 0 -eq $(count_fastboot_devices); then
    reboot_from_device_to_fastboot \
      || fail   "Failed to reboot from android to fastboot."
  fi
  
  cd "${image_dir}" \
    || fail     "Failed to enter image directory."

  output        "Beginning installation."

  install_script='flash-all.sh'
  install_script_reduced='flash-all-reduced.sh'
  install_script_expected='flash-all-expected.sh'
  grep -Ev ^#'|'^\$ $install_script > $install_script_reduced
  cat > "${install_script_expected}" << EOF
fastboot flash bootloader bootloader-${device_code_name}-*.img
fastboot reboot-bootloader
sleep 5
fastboot flash radio radio-${device_code_name}-*.img
fastboot reboot-bootloader
sleep 5
fastboot -w update image-${device_code_name}-*.zip
EOF

  sed \
    -i \
    "
      s/bootloader-${device_code_name}-[a-z0-9]*\.img/bootloader-${device_code_name}-\*\.img/;
      s/radio-${device_code_name}-[a-z0-9]*-[0-9\.]*\.img/radio-${device_code_name}-\*\.img/;
      s/image-${device_code_name}-[a-z0-9]*\.zip/image-${device_code_name}-\*\.zip/;
    " \
    "${install_script_reduced}"

  if ! diff "${install_script_reduced}" "${install_script_expected}" >/dev/null; then
    error_output        "The install script changed.  Review the new script (${install_script}), then edit this script appropriately."
    return 1
  fi

  output        "Flashing bootloader."
  fastboot flash bootloader bootloader-${device_code_name}-*.img \
    || fail     "Failed to flash bootloader."
  reboot_from_fastboot_to_fastboot \
    || fail     "Failed to reboot to fastboot."
  sleep 1
  output        "Flashing radio."
  fastboot flash radio radio-${device_code_name}-*.img \
    || fail     "Failed to flash radio."
  reboot_from_fastboot_to_fastboot \
    || fail     "Failed to reboot to fastboot."
  sleep 1
  output        "Flashing image."

  # Instead of fastboot update, flash individually:
  unzip -o image-${device_code_name}-*.zip \
    || fail     "Failed to unzip image."
  fastboot flash recovery recovery.img \
    || fail     "Failed to flash recovery."
  fastboot flash boot boot.img \
    || fail     "Failed to flash boot."
  fastboot flash system system.img \
    || fail     "Failed to flash system."
  fastboot flash vendor vendor.img \
    || fail     "Failed to flash vendor."
  fastboot flash cache cache.img \
    || fail     "Failed to flash cache."
  fastboot flash userdata userdata.img \
    || fail     "Failed to flash userdata."
  cd - >/dev/null \
    || fail     "Failed to return from image directory."
  output        "Once you provide wifi and Google credentials, Android should start restoring apps."
  output        "Enable USB debugging to continue."
  # Next step does not complete until USB debugging comes online.
  reboot_from_fastboot_to_device \
    || fail     "Failed to reboot from fastboot to android."
  prompt        "Wait for boot to finish (may loop a few times) then hit enter."
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


function count_adb_devices {
  echo $(( $(adb devices | wc -l) - 2 ))
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


function erase_system {
  enter_fastboot \
    || fail     "Failed to enter fastboot."
  output        "Erasing system partition."
  fastboot erase system \
    || fail     "Failed to erase system partition."
}


function erase_boot {
  enter_fastboot \
    || fail     "Failed to enter fastboot."
  output        "Erasing boot partition."
  fastboot erase boot \
    || fail     "Failed to erase boot partition."
}


function write_system {
  rm -rf "${system_image_dir}" \
    || fail     "Failed to remove old system image directory."
  mkdir "${system_image_dir}" \
    || fail     "Failed to create system image directory."
  cd "${system_image_dir}" \
    || fail     "Failed to enter system image directory."
  erase_system \
    || fail     "Failed to erase system partition."
  unzip ../"${image_dir}"/image-${device_code_name}-*.zip \
    || fail     "Failed to unzip system image."
  output        "Writing stock system image."
  fastboot flash system system.img \
    || fail     "Failed to flash system."
  cd - >/dev/null \
    || fail     "Failed to return from system image directory."
}


function write_boot {
  cd "${image_dir}" \
    || fail     "Failed to enter image directory."
  enter_fastboot \
    || fail     "Failed to enter fastboot."
  erase_boot \
    || fail     "Failed to erase boot."
  output        "Writing stock boot image."
  fastboot flash bootloader bootloader-${device_code_name}-*.img \
    || fail     "Failed to flash bootloader."
  cd - >/dev/null \
    || fail     "Failed to return from image directory."
}


function install_twrp_image {
  output        "Beginning TWRP recovery image installation."
  enter_fastboot \
    || fail     "Failed to enter fastboot."
  output        "Beginning TWRP recovery image installation."
  reboot_from_fastboot_to_fastboot \
    || fail     "Failed to reboot from fastboot to fastboot."
  fastboot flash recovery "${twrp_image_file}" \
    || fail     "Failed to flash twrp image:  ${twrp_image_file}"
  reboot_from_fastboot_to_fastboot \
    || fail     "Failed to reboot from fastboot to fastboot."
  reboot_from_fastboot_to_fastboot \
    || fail     "Failed to reboot from fastboot to fastboot."
  # Load new recovery without booting Android.  Then it can initialize itself
  # somehow.  Otherwise Android does something bad to it, and recovery no
  # longer works.  (At least TWRP.)
  enter_recovery 'direct' \
    || fail     "Failed to enter recovery."
  output        "TWRP recovery image installation successful."
}


function install_magisk {
  enter_recovery \
    || fail     "Failed to enter recovery."
  push_magisk \
    || fail     "Failed to push Magisk."
  prompt        "Tap \"Install\", then hit Enter."
  output        "Under /sdcard, scroll down and select:"
  output        "  ${magisk_file}"
  prompt        "Then hit Enter."
  prompt        "Swipe to confirm, then hit Enter."
  prompt        "Wait for install to complete, then hit Enter."
  reboot_from_device_to_device \
    || fail     "Failed to reboot from android to android."
  install_magisk_app \
    || fail     "Failed to install Magisk app."
  prompt        "Check out Magisk, then hit Enter."
}


function install_magisk_app {
  wait_for_adb
  prompt        "When there are no apps installing or updating, hit Enter."
  adb install "${magisk_app_file}"
}


function install_superuser {
  output        "Beginning superuser/supersu installation."
  enter_recovery \
    || fail     "Failed to enter recovery."
  push_superuser \
    || fail     "Failed to push superuser."
  prompt        "Tap \"Install\", then hit Enter."
  output        "Under /sdcard, scroll down and select:"
  output        "  ${superuser_file}"
  prompt        "Then hit Enter."
  prompt        "Swipe to confirm, then hit Enter."
  prompt        "Wait for install to complete, then hit Enter."
  reboot_from_device_to_device \
    || fail     "Failed to reboot from android to android."
}


cookies='cookies.txt'
cookie_url='https://google.com'
ack_url='https://developers.google.com/profile/acknowledgeNotification'
image_file="image_${device_code_name}.zip"
image_dir=''
#system_image_dir="${image_dir}_system"
latest_twrp_image_link=$(latest_twrp_image_link)
twrp_image_file=$(echo "${latest_twrp_image_link}" | sed 's/^.*\///')
magisk_file="Magisk.zip"
magisk_app_file="Magisk.apk"
superuser_file='superuser.zip'
#start_version=$(adb shell getprop ro.build.version.release)
#start_major_version=$(echo "${start_version}" | sed 's/\..*//g')

# TODO:  This does not belong here.
cycle_adb || {
  error_output "Failed to cycle adb."
  exit 1
}

# Get device count after cycle_adb, otherwise lines about "starting daemon"
# throw off the count.
start_adb_count=$(count_adb_devices)
start_fastboot_count=$(count_fastboot_devices)
start_device_count=$(( start_adb_count + start_fastboot_count ))

mkdir -p ${backup_dir} || {
  error_output "Failed to create backup directory:  ${backup_dir}"
  exit 1
}

cd $work_dir || {
  error_output "Failed to enter directory:  ${work_dir}"
  exit 1
}
