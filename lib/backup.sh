#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.




function backup_data {
  backup_file="${backup_dir}/${start_time}.ab"
  #backup_options="-f '${backup_file}' '-apk -all -nosystem -shared'"
  backup_options="-f '${backup_file}' -apk -all -nosystem -shared"
  mkdir -p ${backup_dir} \
    || fail     "Failed to create backup directory:  ${backup_dir}"

  boot_device \
    || fail     "Failed to boot device."
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
  backup_file="${backup_dir}/${start_time}.ab"

  boot_device \
    || fail     "Failed to boot device."

  wait_for_android

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
  
  output        "Rebooting for potential changes from restore operation."
  reboot_device \
    || fail     "Failed to reboot device."
  output        "Restore successful."
}

