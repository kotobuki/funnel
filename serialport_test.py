#!/usr/bin/env python
# encoding: utf-8
"""
untitled.py
"""

import serial
import time
import timeit

sp = serial.Serial('/dev/cu.usbserial-A30009cb', 38400, timeout = 1)
print sp.portstr
print sp

sp.write('Q*')
time.sleep(0.1)
print sp.read(2)

sp.write('?*')
print sp.read(10)

sp.write('KONFIGURATION_1*')
print sp.read(16)
time.sleep(0.1)

def blink():
	sp.write('h*')
	sp.read(2)
	sp.write('l*')
	sp.read(2)

start = time.time()

#t = timeit.Timer('blink()')
#t.timeit(1000)

for i in range(1000):
	blink()

finish = time.time()
print finish - start

def main():
	pass

if __name__ == '__main__':
	main()
