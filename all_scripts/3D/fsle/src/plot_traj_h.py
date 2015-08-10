#python

import numpy as np
import matplotlib.pyplot as plt

xp = 20
yp = 20
zp = 1
pairs = xp*yp*zp*3
sample = 1
time = 12*9

nval = '9999.0000'

f = open('traj.out','r')

traj = np.empty([pairs,4,time])
traj[:] = np.nan

print 'reading'

for t in xrange(time):
 for i in xrange(pairs):
  line = f.readline().split()
  if (line[1]!=nval and line[2]!=nval and line[3]!=nval):
   print line
   traj[i,:,t] = line
f.close()

print 'plotting'

fig = plt.figure()
#plt.scatter(traj[:,1,0],traj[:,2,0])

for i in xrange(0,pairs,sample):
 plt.plot(traj[i,1,:],traj[i,2,:],color='k')

print 'saving'

plt.savefig("traj.png")
