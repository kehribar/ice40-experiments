#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
import sys
import math
import numpy as np
import matplotlib.pyplot as plt

#------------------------------------------------------------------------------
def write_memh(filename, lut):
    fp = open(filename, "w")
    for value in lut:
        value = value & 0xFFFF
        fp.write("{0:0=4X}\n".format(value))
    fp.close()

#------------------------------------------------------------------------------
DEPTH = int(sys.argv[1])
AMPLITUDE = int(sys.argv[2])
FILENAME = "dds_lut.memh"

#------------------------------------------------------------------------------
print ""
print "Generates sinewave lookup table."

#------------------------------------------------------------------------------
print ""
print "Lookup table element size: " + str(DEPTH)
print "Lookup table amplitude: " + str(AMPLITUDE)
print "File path: " + FILENAME + "\r\n"

#------------------------------------------------------------------------------
lut = np.zeros(DEPTH,dtype=np.int)

#------------------------------------------------------------------------------
for x in xrange(0,DEPTH):
	phase = 2.0 * (math.pi / 4) * (float(x) / float(DEPTH))
	lut[x] = AMPLITUDE * math.sin(phase)

#------------------------------------------------------------------------------
write_memh(FILENAME, lut)

#------------------------------------------------------------------------------
plt.figure()
plt.plot(lut)
plt.show()
