#!/share/apps/python/2.7.2/bin/python
import os
import filter_delta
import time

file = 'filter'
months = ['00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36']

for delta in ['250']:
 for a in ['h','l']:
  for yr in ['0008','0009']:
   for d1 in ['0','5']:
    month = []
    for dd in months:
     day = dd+d1
     print day,yr,delta,a

     os.system('rm -fr '+dd)
     os.system('mkdir '+dd)

     os.system('cp ./src/'+file+' '+dd+'/'+dd)
     os.system('chmod a+rx '+dd+'/'+dd)

     if not os.path.isfile(dd+'/fort.21A'):
      os.system('ln -s /tamay/mensa/hycom/scripts/topo0.02/regional.grid.a '+dd+'/fort.21A')
      os.system('ln -s /tamay/mensa/hycom/scripts/topo0.02/regional.grid.b '+dd+'/fort.21')
     
     if a == 'h': 
      if os.path.isfile('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.'+yr+'_'+day+'_00_3zr.A'):
       filter_delta.filter(dd,a,yr,day,delta)
       month.append(dd)
     else:
      if os.path.isfile('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.'+yr+'_'+day+'_00_3zr.A'):
       filter_delta.filter(dd,a,yr,day,delta)
       month.append(dd)

    i = 0

    while i < len(month):
     for dd in month:
      day = dd+d1
      if a == 'h':
       if not os.path.isfile('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.'+yr+'_'+day+'_00_3zr.A'):
        i = len(months)
        print '/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.'+yr+'_'+day+'_00_3zr.A'
      else:
       if not os.path.isfile('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.'+yr+'_'+day+'_00_3zr.A'):
        i = len(months)
        print '/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.'+yr+'_'+day+'_00_3zr.A'

      if (os.path.isfile(dd+'/fort.30A') and os.path.isfile(dd+'/fort.31A') and os.path.isfile(dd+'/fort.32A') and os.path.isfile(dd+'/fort.33A')):
       i=i+1
       print i
       if a == 'h':
        os.system('mv '+dd+'/fort.30A ./output/high-res/'+file+'_02_h_'+delta+'_archv.'+yr+'_'+dd+d1+'_00_r.a')
        os.system('mv '+dd+'/fort.31A ./output/high-res/'+file+'_02_h_'+delta+'_archv.'+yr+'_'+dd+d1+'_00_u.a')
        os.system('mv '+dd+'/fort.32A ./output/high-res/'+file+'_02_h_'+delta+'_archv.'+yr+'_'+dd+d1+'_00_v.a')
        os.system('mv '+dd+'/fort.33A ./output/high-res/'+file+'_02_h_'+delta+'_archv.'+yr+'_'+dd+d1+'_00_w.a')
       else:
        os.system('mv '+dd+'/fort.30A ./output/low-res/'+file+'_02_l_'+delta+'_archv.'+yr+'_'+dd+d1+'_00_r.a')
        os.system('mv '+dd+'/fort.31A ./output/low-res/'+file+'_02_l_'+delta+'_archv.'+yr+'_'+dd+d1+'_00_u.a')
        os.system('mv '+dd+'/fort.32A ./output/low-res/'+file+'_02_l_'+delta+'_archv.'+yr+'_'+dd+d1+'_00_v.a')
        os.system('mv '+dd+'/fort.33A ./output/low-res/'+file+'_02_l_'+delta+'_archv.'+yr+'_'+dd+d1+'_00_w.a')
