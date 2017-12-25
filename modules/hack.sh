#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.

function main {
  # This main function might look better as in-line code, but the 'fail' alias
  # relies on 'return', which doesn't work in that context.
#  backup_data                           || fail "Failed to backup data."
  install_image                         || fail "Failed to install image."
  install_twrp_image                    || fail "Failed to install TWRP recovery image."
  install_superuser                     || fail "Failed to install superuser."
  boot_device                           || fail "DAMMIT"
#  restore_data                          || fail "Failed to restore application data."
  output                                "Success!"
}

time main
