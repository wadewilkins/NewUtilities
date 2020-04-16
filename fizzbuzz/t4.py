#!/usr/bin/env python
for x in range (1,101):
  if x % 3 == 0  and x % 5 == 0:
    print "FizzBuzz"
    continue
  elif x % 3 == 0:
    print "Fizz"
    continue
  elif x % 5 == 0:
    print "Buzz"
    continue
  else:
    print x

