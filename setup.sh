#!/bin/bash

link_files () {
    PIER="$1"
    DESK="$2"
    BASE="$PIER"/"$DESK"
    LIB="$BASE"/lib
    GEN="$BASE"/gen
    MAR="$BASE"/mar
    declare -a DESTS
    DESTS=("$LIB" "$GEN")
    for d in ${DESTS[@]}; do
        mkdir -p "$d"
    done
    DIR=$(pwd)
    ln -s "$DIR"/ucalendar "$LIB"
    ln -s "$DIR"/ucalendar-test.hoon "$GEN"
    ln -s "$DIR"/txt "$BASE"
    ls -s "$DIR"/ics "$BASE"
    ln -s  "$DIR"/ics.hoon "$MAR"
}

if [ "$#" -ne 2 ]; then
    echo "usage: ./setup.sh <PIER> <DESK>"
else
    link_files $1 $2
fi
