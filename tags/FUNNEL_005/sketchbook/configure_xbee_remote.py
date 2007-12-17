#!/usr/bin/env python
# encoding: utf-8

import serial
import time

sp = serial.Serial('/dev/tty.usbserial-0000101D', 9600, timeout = 2)
print sp
print ""

sp.write("+++")
reply = sp.read(3)
if reply == "OK\r":
  print "INFO: Entered command mode successfully"
else:
  print "ERROR: Couldn't enter command mode"

def query(command):
  reply = ""
  sp.write("AT" + command + "\r")
  for i in range(32):
    r = sp.read(1)
    if r == "\r":
      print command + ": " + reply
      return
    else:
      reply += r

def dump_settings():
  query("VR")
  query("MY")
  query("DL")
  query("DH")
  query("ID")
  query("IR")
  query("IT")
  query("IA")
  query("D0")
  query("D1")
  query("D2")
  query("D3")
  query("D4")
  query("D5")
  query("D6")
  query("D7")
  query("D8")
  query("P0")
  query("P1")

print ""
print "*** BEFORE ***"
dump_settings()

print ""
print "*** CONFIG ***"
query("RE")       # reset to factory settings
query("MY 2")     # set my address to 2
query("DL FFFF")  # set destination address to FFFF
query("ID 1111")  # PAN ID is 1111
query("IR 32")    # sampling interval is 50ms
query("IT 2")     # 1 sample before TX
query("D0 2")     # set D0 to AIN
query("D1 2")     # set D1 to AIN
query("D2 2")     # set D1 to AIN
query("P0 2")     # set PWM0 to PWM
query("IA 0001")  # set I/O Input Address to 0x0001
query("WR")       # write all parameters

print ""
print "*** AFTER ***"
dump_settings()
