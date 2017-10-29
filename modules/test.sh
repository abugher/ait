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

    #echo "${test_file}"

    let test_count++
    sc=0
    fc=0
    tc=0

    while read command; do
      let tc++
      if eval "${command}" \
        > /tmp/test."${self_name}"."${test_count}"."${tc}" 2>&1; then
        let sc++
        echo "Check ${tc}:  pass"
      else
        let fc++
        echo "Check ${tc}:  fail"
      fi
    done < "${test_file}"
    echo "Checks passed:  ${sc}/${tc}"
    echo "Checks failed:  ${fc}/${tc}"

    if test '0' == "${fc}"; then
      let success_count++
      echo "Test ${test_count}:  pass"
    else
      let failure_count++
      echo "Test ${test_count}:  fail"
    fi
  done

  echo "Tests passed:  ${success_count}/${test_count}"
  echo "Tests failed:  ${failure_count}/${test_count}"
}

time test_f
