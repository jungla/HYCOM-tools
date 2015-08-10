#python

import os
from myfun import *
from regions import *
from datetime import datetime

start = datetime.now()
N = 10

filed = '/nethome/jmensa/scripts_hycom/3D/archivesDay_all_h_l01'
filey = '/nethome/jmensa/scripts_hycom/3D/archivesYear_all_h_l01'

d = open(filed,'r')
y = open(filey,'r')

# link summer

itime = 0
arch = 0

try:
 os.remove('fort.00A')
except OSError:
 pass
os.symlink('/tamay/mensa/hycom/scripts/topo0.02/regional.grid.a','fort.00A')

for region in range(3):
 itime = 0
 d = open(filed,'r')
 y = open(filey,'r')

 for time in range(22):
  day = d.readline().strip('\n')
  year = y.readline().strip('\n')
 
  lday = digit(day,3)
  lyear = digit(year,4)

  if year == 8:
   season = 0
  else:
   season = 1

  [X1,X2,Y1,Y2,R,lsec,buoys] = regions_lcs(region,season,arch)

  for lhour in ['00','12']:
   itime = itime + 1
 
   fileiu = '/tamay/mensa/hycom/GSa0.0x_l01/l01_h_archv.'+lyear+'_'+lday+'_'+lhour+'_'+R+'_3zu.a'
   fileou = 'fort.u'+digit(itime,2)
   try:
     os.remove(fileou)
   except OSError:
     pass
   os.symlink(fileiu,fileou)
 
   fileiv = '/tamay/mensa/hycom/GSa0.0x_l01/l01_h_archv.'+lyear+'_'+lday+'_'+lhour+'_'+R+'_3zv.a'
   fileov = 'fort.v'+digit(itime,2)
   try:
     os.remove(fileov)
   except OSError:
     pass
   os.symlink(fileiv,fileov)
 
   fileiw = '/tamay/mensa/hycom/GSa0.0x_l01/l01_h_archv.'+lyear+'_'+lday+'_'+lhour+'_'+R+'_3zw.a'
   fileow = 'fort.w'+digit(itime,2)
   try:
     os.remove(fileow)
   except OSError:
     pass
   os.symlink(fileiw,fileow)
 
   fileim = '/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.'+lyear+'_'+lday+'_'+lhour+'.a'
   fileom = 'fort.m'+digit(itime,2)
   try:
     os.remove(fileom)
   except OSError:
     pass
   os.symlink(fileim,fileom)

   try:
     os.remove('traj.out.'+str(R))
   except OSError:
     pass
   
 os.system('cp ./src/advecFSLE_p .')
 os.system('mpirun -n '+str(N)+' ./advecFSLE_p '+str(X1)+' '+str(X2)+' '+str(Y1)+' '+str(Y2)+' '+str(R)+' '+str(year))


 for year in [8,9]: 

  output = 'traj.out.'+str(R)+'.y'+str(year)

  try:
   os.remove(output)
  except OSError:
   pass

  f = open(output,'w')

  for p in range(N):
   file = open('traj.out.'+str(R)+'.'+str(year)+'.'+str(p),'r')
   f.write(file.read())
  f.close()
  
print 'Start', start
print 'End', datetime.now()
print 'Duration', datetime.now()-start

# merge files in one traj file


 
