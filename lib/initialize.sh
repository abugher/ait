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
source $profile                         || fail "Failed to load profile:  ${profile}"
source lib/settings.sh                  || fail "Failed to load:  settings.sh"
source lib/state.sh                     || fail "Failed to load:  state.sh"
source lib/backup.sh                    || fail "Failed to load:  backup.sh"
source lib/download.sh                  || fail "Failed to load:  download.sh"
source lib/install.sh                   || fail "Failed to load:  install.sh"

output                          "Killing adb."
adb kill-server \
  || fail                       "Failed to kill adb server."
output                          "Starting adb."
adb start-server \
  || fail                       "Failed to start adb server."

cd $work_dir \
  || fail                       "Failed to enter directory:  ${work_dir}"

mkdir -p ${backup_dir} \
  || fail                       "Failed to create backup directory:  ${backup_dir}"

device_id=$(adb devices | awk '/\tdevice/ {print $1}')
test "${device_id}" == "${expected_device_id}" \
  || fail                       "Device id:  '${device_id}'  Expected:  '${expected_device_id}'"

latest_twrp_image_link=$(latest_twrp_image_link)
twrp_image_file=$(echo "${latest_twrp_image_link}" | sed 's/^.*\///')
