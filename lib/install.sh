#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.


function unpack_image {
  output        "Unpacking image."
  listing_before=$(ls -1tr)
  unzip -o "${image_file}" \
    || fail     "Failed to unpack image:  ${image_file}"
  listing_after=$(ls -1tr)
  image_dir=$(echo -e "${listing_before}\n${listing_after}" | sort | uniq -u)
  output        "Image unpacked."
  output        "Removing this image and any other old images."
  mkdir -p old_images
  test "" == "${image_prefix}" \
    && fail     "image_prefix is empty.  That's both wrong and dangerous."
  pwd
  output        "Successfully removed old images."
}


function install_image {
  download_stock_image \
    || fail     "Failed to download image."
  unpack_image \
    || fail     "Failed to unpack image."
  boot_fastboot \
    || fail     "Failed to enter fastboot mode."
  
  return_to_dir=$PWD
  output "DEBUG:  image_dir=${image_dir}"
  cd "${image_dir}" \
    || fail     "Failed to enter image directory."

  output        "Beginning installation."

  grep -Ev ^#'|'^\$ "${install_script}" > "${install_script_reduced}"
  sed -i "s/\(image-${device_code_name}-\).*\(\.zip\)$/\1*\2/" flash-all-reduced.sh
  cat > "${install_script_expected}" << EOF
if ! grep -q dtbo.sig \$(which fastboot); then
  echo "fastboot too old"
  exit 1
fi
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
  reboot_fastboot \
    || fail     "Failed to reboot to fastboot."
  sleep 1
  output        "Flashing radio."
  fastboot flash radio radio-${device_code_name}-*.img \
    || fail     "Failed to flash radio."
  reboot_fastboot \
    || fail     "Failed to reboot to fastboot."
  sleep 1
  output        "Flashing image."

  # Instead of fastboot update, flash individually:
  image_unpack_directory=image_unpacked
  mkdir -p $image_unpack_directory \
    || fail     "Failed to create directory:  ${image_unpack_directory}"
  cd $image_unpack_directory \
    || fail     "Failed to enter directory:  ${image_unpack_directory}"
  unzip -o ../image-${device_code_name}-*.zip \
    || fail     "Failed to unzip image."
  # Check that contents are roughly as expected.
  image_file_listing="$(ls | sort)"$'\n'
  test "${expected_image_files}" == "${image_file_listing}" || {
    output      "Expected files:  ${expected_image_files}"
    output      "Actual files:  ${image_file_listing}"
    fail        "The image-wad contains unexpected images.  Check:  ${PWD}"
  }
  fastboot flash recovery recovery.img \
    || fail     "Failed to flash recovery."
  fastboot flash boot boot.img \
    || fail     "Failed to flash boot."
  fastboot flash system system.img \
    || fail     "Failed to flash system."
  if test -e vendor.img; then
    fastboot flash vendor vendor.img \
      || fail     "Failed to flash vendor."
  fi
#  fastboot flash cache cache.img \
#    || fail     "Failed to flash cache."
#  prompt        "Overwrite userdata?  [y,N]"
#  case $response in
#    'Y')
#      ;&
#    'y')
#      fastboot flash userdata userdata.img \
#        || fail     "Failed to flash userdata."
#      ;;
#    '*')
#      ;;
#  esac
  cd $return_to_dir >/dev/null \
    || fail     "Failed change directory:  ${return_to_dir}"
  output        "Once you provide wifi and Google credentials, Android should start restoring apps."
  output        "Enable USB debugging to continue."
  # Next step does not complete until USB debugging comes online.
#  boot_device \
#    || fail     "Failed to reboot from fastboot to android."
  # Don't fail.  There might be no old imagex.
  mv "${image_prefix}"*.zip old_images/
  rm -rf "${image_prefix}"* \
    || fail     "Failed to remove:  ${image_prefix}*"
}


function install_twrp_image {
  download_twrp_image \
    || fail     "Failed to download TWRP image."
  output        "Beginning TWRP recovery image installation."
  boot_fastboot \
    || fail     "Failed to enter fastboot."
  output        "Beginning TWRP recovery image installation."
  reboot_fastboot \
    || fail     "Failed to reboot from fastboot to fastboot."
  fastboot flash recovery "${twrp_image_file}" \
    || fail     "Failed to flash twrp image:  ${twrp_image_file}"
  reboot_fastboot \
    || fail     "Failed to reboot from fastboot to fastboot."
  reboot_fastboot \
    || fail     "Failed to reboot from fastboot to fastboot."
  # Load new recovery without booting Android.  Then it can initialize itself
  # somehow.  Otherwise Android does something bad to it, and recovery no
  # longer works.  (At least TWRP.)
  #boot_recovery 'direct' \
  #  || fail     "Failed to enter recovery."
  # Maybe we can boot the image file without user interaction.  It should be
  # the same as booting that image from the recovery volume.  Will it fix the
  # on-device copy if it knows it was loaded from outside the device?  Let's
  # find out.
  boot_recovery_image "${twrp_image_file}" \
    || fail     "Failed to boot recovery image:  ${twrp_image_file}"
  output        "TWRP recovery image installation successful."
}


function install_superuser {
  download_superuser_zip \
    || fail     "Failed to download superuser."
  output        "Beginning superuser/supersu installation."

  boot_recovery \
    || fail     "Failed to enter recovery."
  prompt        "Tap \"Advanced\", then hit Enter."
  prompt        "Tap \"ADB Sideload\", then hit Enter."
  prompt        "Swipe to start, then hit Enter."
  output        "Sideloading:  ${superuser_file}.zip"
  sleep 2
  adb sideload "${superuser_file}.zip" \
    || fail     "Failed to sideload:  ${superuser_file}.zip"
#  reboot_device \
#    || fail     "Failed to reboot device."
  # Let the system transition from sideload to some other mode, wherein reboot
  # is available.
}


