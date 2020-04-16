#!/usr/bin/env python
for x in range (1,101):
  print_string=x
  if x % 3 == 0:
    print_string="Fizz"
  if x % 5 == 0:
    print_string="Buzz"
  if x % 3 == 0  and x % 5 == 0:
    print_string="FizzBuzz"
  print print_string

