#!/bin/bash

function show_usage() {
    echo "$1 [CAT_OPTIONS] filename"
}


if [ "${#}" -lt 1 ];
then
    show_usage "$0";
    exit -1;
fi

args="${@:1:$#-1}"
filename="${@:$#}"

set --
for arg in "${args[@]}";
do
    set -- "$@" "$arg";
done

cat $@ > $filename