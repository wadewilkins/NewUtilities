#!/bin/bash
for i in {1..5000}
do

number=$RANDOM;
let "number %= 9";
let "number = number + 1";
range=10;
for i in {1..8}; do
  r=$RANDOM;
  let "r %= $range";
  number="$number""$r";
done;

echo $number | nc localhost 4000 
echo $number

done


