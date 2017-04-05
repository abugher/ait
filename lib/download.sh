#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.


function download_latest_stock_image {
  if test -e "${image_file}"; then
    output      "Image file already exists.  Skipping download."
  else
    output      "Use this listing:  https://developers.google.com/android/images"
    output      "Get the image for your device, code named:  ${device_code_name}"
    output      "Place the image at:  ${work_dir}/${image_file}"
    prompt      "Hit enter when the image file is in place."
  fi
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


function download_superuser {
  # The referer hack is for supersu.
  output      "Downloading superuser from ${superuser_link} to ${superuser_file} ."
  wget \
  -O "${superuser_file}" \
  --referer="${superuser_link}" \
  "${superuser_link}"
}



