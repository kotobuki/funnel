#!/usr/bin/env python
# encoding: utf-8

import serial
import time

sp = serial.Serial('/dev/tty.usbserial-A1001hqj', 9600, timeout = 2)
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
  query("D0")
  query("D1")
  query("P0")
  query("AP")

print ""
print "*** BEFORE ***"
dump_settings()

print ""
print "*** CONFIG ***"
query("RE")       # reset to factory settings
query("MY 1")     # set my address to 1
query("DL 2")     # set destination address to 2
query("ID 1111")  # PAN ID is 1111
query("AP 2")     # set API mode to API with escape characters
query("WR")       # write all parameters

print ""
print "*** AFTER ***"
dump_settings()

print ""
query("CN")       # exit command mode
