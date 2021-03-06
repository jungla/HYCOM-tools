#!/usr/bin/env python
import pyvtk
import hio
import numpy as np
import gc
from myfun import *
from regions import *
import matplotlib.pyplot as plt
from scipy.interpolate import griddata

gc.enable()

# HYCOM vars

idm = 300
jdm = 300
kdm = 500

m    = np.zeros((idm,jdm))

idt = 1573
jdt = 1073

# trajs vars

xp = 20
yp = 20
zp = 1
pairs = xp*yp*zp*3
sample = 1
time = 12*10 # one position every 2 hours for 10 days.
nval = '9999.0000'
filename = 'traj.out'
endT = 10

# read trajs
print 'reading trajs'

f = open(filename,'r')

traj = np.empty([pairs,4,time])
traj[:] = np.nan

for t in xrange(time):
 for i in xrange(pairs):
  line = f.readline().split()
  if (line[1]!=nval and line[2]!=nval and line[3]!=nval):
#   print line
   traj[i,:,t] = line
f.close()

# read grid
print 'reading HYCOM grid'

file = '/tamay/mensa/hycom/GSa0.02/expt_01.6/data/regional.grid.a'

tlon = hio.hycomread_2D(file,idt,jdt,0)
tlat = hio.hycomread_2D(file,idt,jdt,1)

for arch in range(1):

 if arch == 0:
  filed = '/nethome/jmensa/scripts_hycom/3D/archivesDay_all_h_w_l01'
  filey = '/nethome/jmensa/scripts_hycom/3D/archivesYear_all_h_w_l01'
 else:
  filed = '/nethome/jmensa/scripts_hycom/3D/archivesDay_all_l_w_l01'
  filey = '/nethome/jmensa/scripts_hycom/3D/archivesYear_all_l_w_l01'

 for region in range(0,1):
  itime = 0
  df = open(filed,'r')
  yf = open(filey,'r')
 
  trajs_ml = np.zeros([traj.shape[0],2])  
  trajs_t  = []  

  fig = plt.figure()

  for i in xrange(0,pairs,sample):
   plt.plot(traj[i,1,0:endT*12],traj[i,2,0:endT*12],color='k',zorder = 1)


  for time in range(endT):
   day = df.readline().strip('\n')
   year = yf.readline().strip('\n')
   
   lday = digit(day,3)
   lyear = digit(year,4)
 
   if year == 8:
    season = 0
   else:
    season = 1
   
   [X1,X2,Y1,Y2,R,lsec,buoys] = regions_lcs(region,season,arch)

   for hour in range(2):
    itime = itime + 1

    if hour == 0:
     hr = '00'
    else:
     hr = '12'

    print time
    print hour
    print R

    if arch == 0:
     filem = '/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.'+lyear+'_'+lday+'_'+hr+'.a' 
    else:
     filem = '/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.'+lyear+'_'+lday+'_'+hr+'.a' 

    print filem

    tm = hio.hycomread_2D(filem,idt,jdt,5)/9806
    m[:,:] = tm[Y1:Y2,X1:X2]

    lon = tlon[Y1:Y2,X1:X2]
    lat = tlat[Y1:Y2,X1:X2]
   
    values = np.zeros(idm*jdm)
    coords = np.zeros([idm*jdm,2])

    for i in range(idm):
     for j in range(jdm):
	values[j+i*jdm] = m[i,j]
	coords[j+i*jdm,0] = i
	coords[j+i*jdm,1] = j
     
    # particle position needs to interpolated to regular grid where MLD is defined
    temp_traj = traj[:,1:3,time*12]
    tmp = griddata(coords, values, temp_traj, method='linear')
   
    ml2part = tmp < traj[:,3,time*12]
    print 'particles leaving:',list(ml2part).count(True)
    plt.scatter(temp_traj[ml2part,0],temp_traj[ml2part,1],zorder = 10)
    plt.gca().set_xlim([0,300])
    plt.gca().set_ylim([0,300])

    if itime == 11:
     itime = itime - 10 

  if arch == 0:
   label = 'trajMLD_h_archv_'+R+'_ML.png'
  else:
   label = 'trajMLD_l_archv_'+R+'_ML.png'

  print label
  plt.savefig(label)
  plt.close()

  df.close()
  yf.close()
