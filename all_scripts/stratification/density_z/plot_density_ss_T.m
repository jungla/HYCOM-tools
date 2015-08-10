clear all;

gridbfid=fopen('~/hycom/scripts/topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region

ijdm = idm*jdm;

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,ijdm,1);
tlat = hycomread(file,ijdm,2);

tpscx = hycomread(file,ijdm,10);
tpscy = hycomread(file,ijdm,11);

tpscx = reshape(tpscx,idm,jdm);
tpscy = reshape(tpscy,idm,jdm);
tlon = reshape(tlon,idm,jdm);
tlat = reshape(tlat,idm,jdm);

rmin = 33.5; % good values for 1000m: 33.5 37.0
rmax = 37.0; % values for ml:         33.0 35.0

dmax = 1000; % depth

dayi = 1;    % variables for day loop
dayf = 366;  %
dstep = 1;   %

step = 400;  % mesh # points

N = 30;      % total number of layers, don't touch this. just change the displayed depth

for region = 1:4

 if (region == 1)
  X1 = 472
  X2 = 839
  Y1 = 77
  Y2 = 267
  R = 'A'
 elseif (region == 2)
  X1 = 840
  X2 = 1279
  Y1 = 77
  Y2 = 267
  R = 'B'
 elseif (region == 3)
  X1 = 619
  X2 = 986
  Y1 = 774
  Y2 = 900
  R = 'C'
 else
  X1 = 472
  X2 = 766
  Y1 = 393
  Y2 = 584
  R = 'D'
 end

lon = tlon(X1:X2,1);
lat = tlat(1,Y1:Y2);

for arch = 1:2

for year = 8:9

for day  = dayi:dstep:dayf-dstep
 if ((year ~= 8) || (day ~= 1))
 if ((year == 9) && (day >= 133))
 break;
 end

 lyear = num2str(year);
 lday = num2str(day);

 if(day < 100)
  lday = strcat('0',lday);
  if(day < 10)
   lday = strcat('0',lday);
  end
 end

 lday
 lyear

for s = 1:2 % type of section

 if (arch == 1)
  file  = strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/high-res/',R,'/density_s_h_016_archv.000',lyear,'_',lday,'_',R,num2str(s),'s_00.dat');
  file1 = strcat('/media/sdd1/hycom/scripts/stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.000',lyear,'_',lday,'_00.a');
 else
  file  = strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/low-res/',R,'/density_s_l_016_archv.000',lyear,'_',lday,'_',R,num2str(s),'s_00.dat');
  file1 = strcat('/media/sdd1/hycom/scripts/stratification/mixedlayer/output/low-res/mixlayer_l_016_archv.000',lyear,'_',lday,'_00.a');
 end

 section = textread(file);

%%%%%%%%%%%%%%%%%%%%%%%%
% compute ML, for each day, for each resolution
%%%%%%%%%%%%%%%%%%%%%%%%%

% the date is messed up... i fix it.

 tml = hycomread(file1,ijdm,1);
 tml(tml > 10^10) = NaN;
 tml = reshape(tml,idm,jdm);
 tml = tml./9806;

 mld = avg_region(tml,tpscx,tpscy,X1,X2,Y1,Y2,s);

 ch = figure();

 ids = X2-X1+1;
 jds = Y2-Y1+1;

 if (s == 1)
  fd = ids*N;
  x = lon;
 else
  fd = jds*N;
  x = lat;
 end

 minX = min(section(1:fd,4));
 maxX = max(section(1:fd,4));
 minY = min(section(1:fd,2));
 maxY = max(section(1:fd,2));

 XI = minX:(maxX-minX)/step:maxX;
 YI = minY:(maxY-minY)/step:maxY;
 YI = YI';
 X  = section(1:fd,4);
 Y  = section(1:fd,2);
 ZI = griddata(X,Y,section(1:fd,3),XI,YI); 

if (arch == 1)

 imagesc(XI,YI,ZI);
 hold on;
 scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')
 hold on;
 plot(x,mld,'w');
 hold off;
 colorbar;
 caxis([rmin rmax]);
 set(gca,'YDir','reverse');
 ylim([0 dmax]);
 label = strcat('/media/sdd1/hycom/scripts/stratification/density_z/plot/',num2str(dmax),'/high-res/density_s_',num2str(dmax),'_',lyear,'_',lday,'_h_',R,num2str(s),'s.eps')
 title(strcat(['Density section of region ',R,' Year ',lyear,', day ',lday]));
 print(ch,'-dpsc2',label);

else
 imagesc(XI,YI,ZI);
 hold on;
 scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')
 hold on;
 plot(x,mld,'w');
 hold off;
 colorbar;
 caxis([rmin rmax]);
 set(gca,'YDir','reverse');
 ylim([0 dmax]);
 label = strcat('/media/sdd1/hycom/scripts/stratification/density_z/plot/',num2str(dmax),'/low-res/density_s_',num2str(dmax),'_',lyear,'_',lday,'_h_',R,num2str(s),'s.eps')
 title(strcat(['Density section of region ',R,' Year ',lyear,', day ',lday]));
 print(ch,'-dpsc2',label);

end

close all;

end % end section
end % end arch
end % end day
end % end if day
end % end if day
end % end region
