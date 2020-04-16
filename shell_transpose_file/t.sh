#!/bin/bash

aline="$(head -n 1 file.txt)"
set -- $aline
colNum=$#

#set -x
while read line; do
  set -- $line
  for i in $(seq $colNum); do
    eval col$i="\"\$col$i \$$i\""
  done
done < file.txt

for i in $(seq $colNum); do
  eval echo \${col$i}
done

