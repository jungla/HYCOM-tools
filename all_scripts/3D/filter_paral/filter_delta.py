#!/share/apps/python/2.7.2/bin/python
import os
import subprocess

def filter(dd,a,yr,day,delta):
 os.chdir(dd)
 os.system('touch      fort.30A fort.31A fort.32A fort.33A fort.00A fort.01A fort.02A fort.03A')
 os.system('/bin/rm -f fort.30A fort.31A fort.32A fort.33A fort.00A fort.01A fort.02A fort.03A')

 if a == 'h':
  filear = '/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.'+yr+'_'+day+'_00_3zr.A'
  fileau = '/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.'+yr+'_'+day+'_00_3zu.A'
  fileav = '/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.'+yr+'_'+day+'_00_3zv.A'
  fileaw = '/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.'+yr+'_'+day+'_00_3zw.A'
 else:
  filear = '/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.'+yr+'_'+day+'_00_3zr.A'
  fileau = '/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.'+yr+'_'+day+'_00_3zu.A'
  fileav = '/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.'+yr+'_'+day+'_00_3zv.A'
  fileaw = '/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.'+yr+'_'+day+'_00_3zw.A'

 os.system('ln -fs '+filear+' ./fort.00A')
 os.system('ln -fs '+fileau+' ./fort.01A')
 os.system('ln -fs '+fileav+' ./fort.02A')
 os.system('ln -fs '+fileaw+' ./fort.03A')
  
 file = './'+dd
 delta = delta+'000'
 args = [file,'472','1280','80','273',delta]
 proc = subprocess.Popen(args)
#  proc.wait()

 os.chdir('..')
