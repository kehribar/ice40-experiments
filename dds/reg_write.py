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
print "Port name: " + sys.argv[1]
print "Baud rate: " + str(int(sys.argv[2]))

#------------------------------------------------------------------------------
print "Address: " + str(int(sys.argv[3]))
print "Value: " + str(int(sys.argv[4]))

#------------------------------------------------------------------------------
buf = [0] * 256

#------------------------------------------------------------------------------
print "\r\nSerial port preparing ...\r\n"
sp = serial.Serial(sys.argv[1], sys.argv[2], timeout=0.001)
time.sleep(0.1)
print "Start the test ..."

# Generate transmission buffer
buf[0] = int(sys.argv[3])
buf[1:5] = bytearray(struct.pack(">i", int(sys.argv[4])))

sp.write(buf[0:5])

# Sleep ~1ms
time.sleep(0.001)

# # Request a register
# buf[0] = 0x80 + 0x0F
# sp.write(buf[0:1])
# rbuf = bytearray(sp.read(4))
# print ' '.join('%02x'%i for i in rbuf)

# # Sleep ~1ms
# time.sleep(0.001)	

#------------------------------------------------------------------------------
sp.close()
