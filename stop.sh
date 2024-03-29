#!/bin/bash

current=$(
  cd "$(dirname "$0")" || exit 1
  pwd
)
datadir=$current/ridf

time=$(date)

# stop signal sending
# shellcheck disable=SC1091
source "$current/pybabilib/.venv/bin/activate"
python "$current/pybabilib/src/sto.py"

# this is DAQ log setting (not necessary)
# get ridf file name
ridf_file=$(find "$datadir"/*.ridf | sort -nr | head -n 1)
file=${ridf_file##*/}
run_info=${file%.*}

last_line=$(tail -n 1 "$current/log")
if [[ "$last_line" =~ "---" ]]; then
  exit 0
fi

# log setting
is_firstrun=true
shopt -s extglob lastpipe
tac "$current/log" | while read -r line; do
  log=$(echo "$line" | cut -f 2 -s -d "@")
  if [ "$log" = "" ]; then
    continue
  fi

  if [[ "$log" =~ $run_info ]]; then
    echo "${time} stop" >>"$current/log"
  else
    echo "${time} stop   @${run_info}" >>"$current/log"
  fi

  echo "---" >>"$current/log"
  is_firstrun=false
  break
done

if [ $is_firstrun = "true" ]; then
  echo "${time} stop   @${run_info}" >>"$current/log"
  echo "---" >>"$current/log"
fi
