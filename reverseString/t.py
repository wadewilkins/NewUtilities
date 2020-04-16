#!/usr/bin/env python
import sys

#s = sys.argv[1]

def main(s):
   s1 = ''
   for c in s:
       s1 = c + s1  # appending chars in reverse order
   print s1

if __name__ == "__main__":
  s = sys.argv[1]
  main(s)
