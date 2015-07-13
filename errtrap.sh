#!/bin/bash

stderr_log="/tmp/std.err"
err_log="/tmp/err.log"
exec 2>"$stderr_log"

THISSCRIPT=$(readlink -e $0)
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
function error() {
    LASTERR=$(tail -n 1 $stderr_log)
    if [ -z "$LASTERR" ]; then
      return
    fi
    LINENR=$(echo $LASTERR | awk {'print $3'} | cut -d':' -f1)
    COMMAND=$(sed -n ${LINENR}p ${THISSCRIPT})
    tput setaf 1; tput smul 
    echo $LASTERR
    tput sgr0; tput bold
    echo $COMMAND
    tput sgr0
    echo $(date) >> $err_log
    echo $LASTERR >> $err_log
    echo $COMMAND >> $err_log
    echo "----" >> $err_log
    exit 1
}
#trap error EXIT
trap error ERR

function do_a_err {
    gclient sync -v
}

# ENTRY
do_a_err
