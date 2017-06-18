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
print "Test size: " + str(int(sys.argv[3]))

#------------------------------------------------------------------------------
TEST_SIZE = int(sys.argv[3])
buf = [0] * TEST_SIZE

#------------------------------------------------------------------------------
print "\r\nSerial port preparing ...\r\n"
sp = serial.Serial(sys.argv[1], sys.argv[2], timeout=30)
time.sleep(1)
rbuf = sp.read(sp.in_waiting)

#------------------------------------------------------------------------------
for x in xrange(0,TEST_SIZE):
	buf[x] = int(random.random() * 255)

buf = bytearray(buf)

#------------------------------------------------------------------------------
while True:
	start = datetime.datetime.now()
	sp.write(buf)
	rbuf = bytearray(sp.read(TEST_SIZE))
	end = datetime.datetime.now()

	diff = end - start
	elapsed_ms = (diff.days * 86400000) + (diff.seconds * 1000) + (diff.microseconds / 1000)
 
	speed = TEST_SIZE / elapsed_ms

	print "Elapsed time: " + str(elapsed_ms) + " ms | Speed: " + str(speed) + " kB/sec" + " | Read length: " + str(len(rbuf)) + " bytes"	

	for x in xrange(0,TEST_SIZE):
		if(rbuf[x] != buf[x]):
			print "Mismatch!"
			sys.exit(0)

#------------------------------------------------------------------------------
sp.close()
