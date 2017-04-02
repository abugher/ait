#!/bin/bash
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See WTFPL.txt or http://www.wtfpl.net/ for more
# details.


output_prefix='| '
# expand_aliases makes aliases work.  It's not set in scripts by default.
shopt -s expand_aliases


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



