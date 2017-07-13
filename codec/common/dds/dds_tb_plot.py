#!/usr/bin/env python
#------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------
import matplotlib.pyplot as plt
import numpy
import csv

time = []
val = []
quadrant = []


f = open('dds_tb_log.txt', 'rt')

reader = csv.reader(f)
for row in reader:
	time.append(row[0])
	val.append(row[1])
	quadrant.append(row[2])

plt.figure()
plt.subplot(2,1,1)
plt.plot(time,val,'-')
plt.subplot(2,1,2)
plt.plot(time,quadrant,'r*')
plt.draw()
plt.show()
