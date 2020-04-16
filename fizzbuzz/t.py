#!/usr/bin/env python
for x in range (1,101):
  if x % 3 == 0  and x % 5 == 0:
    p_s = "FizzBuzz"
  elif x % 3 == 0:
    p_s = "Fizz"
  elif x % 5 == 0:
    p_s = "Buzz"
  else:
    p_s = x
  print p_s

