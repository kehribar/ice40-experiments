#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
import sys
import time
import serial
import random
import datetime
import thread, struct

#------------------------------------------------------------------------------
BAUD_RATE = 1000000
PORT_NAME = "/dev/ttyUSB1"

F_INCREMENT = 60000000.0 / pow(2,32)

#------------------------------------------------------------------------------
ADDRESS = 0x01

#------------------------------------------------------------------------------
buf = [0] * 256

#------------------------------------------------------------------------------
print "\r\nSerial port preparing ...\r\n"
sp = serial.Serial(PORT_NAME, BAUD_RATE, timeout=0.001)
time.sleep(0.1)
print "Start the test ..."

while True:	

	for x in xrange(5000,70000):	
		phaseInc = int(float(x) / F_INCREMENT);

		buf[0] = ADDRESS
		buf[1:5] = bytearray(struct.pack(">i", phaseInc))

		sp.write(buf[0:5])

		# Sleep ~1ms
		time.sleep(0.0001)

#------------------------------------------------------------------------------
sp.close()
