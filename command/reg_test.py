#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
import sys
import time
import serial
import random
import datetime

#------------------------------------------------------------------------------
print "Port name: " + sys.argv[1]
print "Baud rate: " + str(int(sys.argv[2]))

#------------------------------------------------------------------------------
buf = [0] * 256

#------------------------------------------------------------------------------
print "\r\nSerial port preparing ...\r\n"
sp = serial.Serial(sys.argv[1], sys.argv[2], timeout=0.001)
time.sleep(1)

print "Start the test ..."

rbuf = sp.read(sp.in_waiting)

i = 0

while True:

	# Generate transmission buffer
	buf[0] = 0x7F
	buf[1] = 0xAA
	buf[2] = 0xBB
	buf[3] = (i % 256)
	buf[4] = 0x00
	sp.write(buf[0:5])

	# Sleep ~1ms
	time.sleep(0.001)

	# Request a register
	buf[0] = 0x80 + 0x0F
	sp.write(buf[0:1])
	rbuf = bytearray(sp.read(4))
	print ' '.join('%02x'%i for i in rbuf)

	# Sleep ~1ms
	time.sleep(0.001)	

	# Iterate packet ...
	i += 1

#------------------------------------------------------------------------------
sp.close()
