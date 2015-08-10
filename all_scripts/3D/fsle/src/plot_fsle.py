#python
from hio import *

import matplotlib.pyplot as plt
from matplotlib import mpl
 

filename = 'fslf10000'
IDM = 100
JDM = 100

for k in range(1):
 var = binaryread_2D(filename,IDM,JDM,k)

fig = plt.figure()

plt.contourf(var,cmap=mpl.cm.hot)


plt.savefig("fsle.png")
