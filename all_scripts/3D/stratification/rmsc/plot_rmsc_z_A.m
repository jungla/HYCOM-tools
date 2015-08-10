clear all;

gridbfid=fopen('~/hycom/scripts/topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
ijdm = idm*jdm;

dmax = 1000;
dday = 1;

dayi = 1;    % variables for day loop
dayf = 50;  %
dstep = 1;   %

maxr = 0;
minr = 100;
maxN2 = -100;
minN2 = 100;

maxtr = -10;
mintr = 10;
maxtN2 = -10;
mintN2 = 10;


[X1,X2,Y1,Y2,R] = regions(region);

X1 = 1
X2 = idm
Y1 = 1
Y2 = jdm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first check overall max rmsc and frequency to plot...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 N = 22;
 M = size(text,1);

for arch = 1:2

for time  = dayi:dstep:dayf-dstep

day   = textread('/media/sdd1/hycom/scripts/3D/archivesDay');
year  = textread('/media/sdd1/hycom/scripts/3D/archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

 lday
 lyear

clear r z N2

 if (arch == 1)
  file  = strcat('/media/sdd1/hycom/scripts/3D/stratification/rmsc/output/high-res/',R,'/rmsc_h_016_archv.',lyear,'_',lday,'_',R,'0_00.dat');
  text  = textread(file);
 else
  file  = strcat('/media/sdd1/hycom/scripts/3D/stratification/rmsc/output/low-res/',R,'/rmsc_l_016_archv.',lyear,'_',lday,'_',R,'0_00.dat');
  text  = textread(file);
 end

  depth  = textread('/media/sdd1/hycom/scripts/3D/layersDepth');
 
  z  = depth(:,1); % depth
  r  = text(:,2);  % rmsc
  z  = z(r<10^8);
  r  = r(r<10^8);

% add a first point at z = 0.

 % interpolation vectors
 zi = 0:1:dmax;
 ri = interp1(z,r,zi,'linear');

 if (arch == 1)
  tri  = ri;
 else
  maxtr  = max(maxtr,max(tri-ri));
  mintr  = min(mintr,min(tri-ri));
 end

 maxr = max(maxr,max(ri));
 minr = min(minr,min(r));

end % days
end % days

maxr
minr

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %          real computation
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first check overall max rmsc and frequency to plot...

file = '/media/sdd1/hycom/scripts/topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

 
 itime = 0;

 M = size(text,1);

for arch = 1:2

for time  = dayi:dstep:dayf-dstep

day   = textread('/media/sdd1/hycom/scripts/3D/archivesDay');
year  = textread('/media/sdd1/hycom/scripts/3D/archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

 lday
 lyear

clear r z N2

 itime = itime + 1;

 if (arch == 1)
  file  = strcat('/media/sdd1/hycom/scripts/3D/stratification/rmsc/output/high-res/',R,'/rmsc_h_016_archv.',lyear,'_',lday,'_',R,'0_00.dat');
  text  = textread(file);
 else
  file  = strcat('/media/sdd1/hycom/scripts/3D/stratification/rmsc/output/low-res/',R,'/rmsc_l_016_archv.',lyear,'_',lday,'_',R,'0_00.dat');
  text  = textread(file);
 end

  depth  = textread('/media/sdd1/hycom/scripts/3D/layersDepth');

  z  = depth(:,1); % depth
  r  = text(:,2);  % rmsc
  z  = z(r<10^8);
  r  = r(r<10^8);

% add a first point at z = 0.

 % interpolation vectors
 zi = 0:1:dmax;
 ri = interp1(z,r,zi,'linear');
 

%%%%%%%%%%%%%%%%%%%%%%%%
% compute ML, for each day, for each resolution

% the date is messed up... i fix it.

 day = str2num(lday);

 
 if (arch == 1)
  file1 = strcat('~/hycom/scripts/stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.',lyear,'_',lday,'_00.a');
 else
  file1 = strcat('~/hycom/scripts/stratification/mixedlayer/output/low-res/mixlayer_l_016_archv.',lyear,'_',lday,'_00.a');
 end

 tml = hycomread(file1,idm,jdm,ijdm,1);
 tml = tml./9806;

 mld = avg_region(tml,tpscx,tpscy,X1,X2,Y1,Y2,0)

%%%%%%%%%%%%%%%%%%%%%%% 
%% plot rmsc and N2 ina single graph,
 
 [ch] = figure;

% the date is messed up... i fix it.

 if (arch == 1)

 tri = ri;

 p1 = plot(r,z,'+',ri,zi,'linewidth',2);
 title(['RMS Speed (region ',R,', high res), day: ',lday,', year: ',lyear],'fontsize',15);
 set(gca,'ydir','rev')
 axis([minr maxr 0 dmax])
 xlabel('|c| (m/s)','FontSize',14)
 ylabel('Depth (m)','FontSize',14)
 hold on;
 plot([minr maxr],[mld mld]);

 label = strcat('/media/sdd1/hycom/scripts/3D/stratification/rmsc/plot/',num2str(dmax),'/high-res/rmsc_',num2str(dmax),'_',lyear,'_',lday,'_h_',R,'0.eps')
 'saving...'
 print(ch,'-dpsc2',label)

 else

 p1 = plot(r,z,'+',ri,zi,'linewidth',2);
 title(['RMS Speed (region ',R,', low res), day: ',lday,', year: ',lyear],'fontsize',15);
 set(gca,'ydir','rev')
 axis([minr maxr 0 dmax])
 xlabel('|c| (m/s)','FontSize',14)
 ylabel('Depth (m)','FontSize',14)
 hold on;
 plot([minr maxr],[mld mld]);


 label = strcat('/media/sdd1/hycom/scripts/3D/stratification/rmsc/plot/',num2str(dmax),'/low-res/rmsc_',num2str(dmax),'_',lyear,'_',lday,'_l_',R,'0.eps')
 'saving...'
 print(ch,'-dpsc2',label)

 close;
 figure();
 %% plot differences...


 p1 = plot(tri-ri,zi,'linewidth',2);
 title(['RMS Speed (region ',R,', high-res - low-res), day: ',lday,', year: ',lyear],'fontsize',15);

 set(gca,'ydir','rev')
 axis([mintr maxtr 0 dmax])
 xlabel('|c| (m/s)','FontSize',14)
 ylabel('Depth (m)','FontSize',14)
 hold on;
 plot([mintr maxtr],[mld mld]);

 label = strcat('/media/sdd1/hycom/scripts/3D/stratification/rmsc/plot/',num2str(dmax),'/diff/rmsc_',num2str(dmax),'_',lyear,'_',lday,'_diff_',R,'0.eps')
 'saving...'
 print(ch,'-dpsc2',label)

 close all;

 end 

end % end day
end % end arch

end % end region
