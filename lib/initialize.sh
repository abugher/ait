#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.


function initialize {
  cd "${self_path}" || {
    echo "ERROR:  Failed to go home:  ${self_path}" >&2
    exit 1
  }
  old_path=$OLDPWD

  source lib/communication.sh   || {
    echo "ERROR:  Failed to load:  communication.sh" >&2
    exit 1
  }
  source lib/settings.sh        || fail "Failed to load:  settings.sh"
  source lib/state.sh           || fail "Failed to load:  state.sh"
  source lib/backup.sh          || fail "Failed to load:  backup.sh"
  source lib/download.sh        || fail "Failed to load:  download.sh"
  source lib/install.sh         || fail "Failed to load:  install.sh"
  initialize_adb                || fail "Failed to initialize ADB."

  cd "${old_path}"              || fail "Failed to return to:  '${old_path}'"
}


function initialize_adb {
  output                        "Killing adb."
  adb kill-server               || fail "Failed to kill adb server."
  output                        "It's dead.  Waiting, then starting again..."
  sleep 2
  output                        "Starting adb."
  adb start-server              || fail "Failed to start adb server."
}
