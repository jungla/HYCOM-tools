#python

import os
from myfun import *

filed = '/nethome/jmensa/scripts_hycom/3D/archivesDay_all_h_l01'
filey = '/nethome/jmensa/scripts_hycom/3D/archivesYear_all_h_l01'

d = open(filed,'r')
y = open(filey,'r')

# link summer

itime = 0

R = 'A'

for time in range(11):
 day = d.readline().strip('\n')
 year = y.readline().strip('\n')

 lday = digit(day,3)
 lyear = digit(year,4)

 for lhour in ['00','12']:
  itime = itime + 1

  fileiu = '/tamay/mensa/hycom/GSa0.0x_l01/l01_h_archv.'+lyear+'_'+lday+'_'+lhour+'_'+R+'_3zu.A'
  fileou = 'fort.u'+digit(itime,2)
  try:
    os.remove(fileou)
  except OSError:
    pass
  os.symlink(fileiu,fileou)

  fileiv = '/tamay/mensa/hycom/GSa0.0x_l01/l01_h_archv.'+lyear+'_'+lday+'_'+lhour+'_'+R+'_3zv.A'
  fileov = 'fort.v'+digit(itime,2)
  try:
    os.remove(fileov)
  except OSError:
    pass
  os.symlink(fileiv,fileov)

  fileiw = '/tamay/mensa/hycom/GSa0.0x_l01/l01_h_archv.'+lyear+'_'+lday+'_'+lhour+'_'+R+'_3zw.A'
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


# link winter
#for time in range(11):
