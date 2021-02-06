#!/usr/bin/env bash

baseurl="https://raw.githubusercontent.com/eggert/tz/master/"
files=("northamerica" "asia" "australasia" "africa"
         "antarctica" "europe" "southamerica")

if [[ $# -ne 1 ]]; then
  echo "usage: ./import-timezones.sh <TARGET_DIRECTORY>" && exit 1
fi

targetdir="$1"

for val in ${files[@]}; do
  echo "downloading $val" && wget -c "$baseurl$val" -O "$targetdir/$val.txt"
done

echo "done"
