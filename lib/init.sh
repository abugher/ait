#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.

start_time="$(date "+%Y-%m-%d_%H:%M:%S")"
source lib/communication.sh             || {
  echo "ERROR:  Failed to load:  communication.sh" >&2
  exit 1
}
source lib/settings.sh                  || fail "Failed to load:  settings.sh"
source lib/state.sh                     || fail "Failed to load:  state.sh"
source lib/backup.sh                    || fail "Failed to load:  backup.sh"
source lib/download.sh                  || fail "Failed to load:  download.sh"
source lib/install.sh                   || fail "Failed to load:  install.sh"

cycle_adb || {
  error_output "Failed to cycle adb."
  exit 1
}

# Get device count after cycle_adb, otherwise lines about "starting daemon"
# throw off the count.
start_adb_count=$(count_adb_devices)
start_fastboot_count=$(count_fastboot_devices)
start_device_count=$(( start_adb_count + start_fastboot_count ))

cd $work_dir || {
  error_output "Failed to enter directory:  ${work_dir}"
  exit 1
}

mkdir -p ${backup_dir} || {
  error_output "Failed to create backup directory:  ${backup_dir}"
  exit 1
}

latest_twrp_image_link=$(latest_twrp_image_link)
twrp_image_file=$(echo "${latest_twrp_image_link}" | sed 's/^.*\///')
