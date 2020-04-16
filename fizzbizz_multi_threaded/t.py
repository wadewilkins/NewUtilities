#! /usr/bin/env python

import sys
import threading

n = 100 if len(sys.argv) == 1 else int(sys.argv[1])
event = threading.Event()

def fizzbuzz(i):
    event.wait()
    fizz = i % 3 == 0
    buzz = i % 5 == 0
    if not (fizz or buzz):
        print str(i) + ': ' + str(i) + '\n'
        return
    message = []
    if fizz:
        message.append('Fizz')
    if buzz:
        message.append('Buzz')
    print str(i) + ': ' + ''.join(message) + '\n'

threads = []
for i in xrange(1, n + 1):
    t = threading.Thread(target=fizzbuzz, args=(i,))
    t.start()
    threads.append(t)

event.set()

for t in threads:
    t.join()
