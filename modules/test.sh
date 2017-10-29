#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.

function test_f {
  # This main function might look better as in-line code, but the 'fail' alias
  # relies on 'return', which doesn't work in that context.

  test_count=0
  failure_count=0
  success_count=0

  for test_file in "${self_path}/api_tests.d/"*; do
    if test "${self_path}/api_tests.d/*" == "${test_file}"; then
      continue
    fi

    printf "Check %03d:       pass\n" ${tc}
    echo "Next test:     $(basename "${test_file}")"

    let test_count++
    sc=0
    fc=0
    tc=0

    commands=()
    while read command; do
      commands+=("${command}")
    done < "${test_file}"
    
    for command in "${commands[@]}"; do
      let tc++
      if eval "${command}" \
        > /tmp/test."${self_name}"."${test_count}"."${tc}" 2>&1; then
        let sc++
        printf "Check %03d:       pass\n" ${tc}
      else
        let fc++
        printf "Check %03d:       fail\n" ${tc}
      fi
    done
    printf "Checks passed:   %03d/%03d\n" ${sc} ${tc}
    printf "Checks failed:   %03d/%03d\n" ${fc} ${tc}

    if test '0' == "${fc}"; then
      let success_count++
      printf "Test  %03d:       pass\n" ${tc}
    else
      let failure_count++
      printf "Test  %03d:       fail\n" ${tc}
    fi
  done

  printf "Tests passed:   %03d/%03d\n" ${sc} ${tc}
  printf "Tests failed:   %03d/%03d\n" ${fc} ${tc}
}


time test_f
