clear all;

gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
ijdm = idm*jdm;

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

dayi = 1;    % variables for day loop
dayf = 50;  %
dstep = 1;   %

maxr = 1;
minr = -1;
maxtr = -10;
mintr = 10;

N = 22;

for region = 1:4

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 1:2

for time  = 1:2

day   = textread('../archivesDay_2');
year  = textread('../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:4

depth = readline('../layersDepth_4',did);
depthid = str2num(readline('../layersDepthID_4',did));
depth


if (arch == 1)
 file   = strcat('./output/high-res/F_h_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
else
 file   = strcat('./output/low-res/F_l_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
end

Ft  = binaryread(file,idm,jdm,ijdm,depthid);
Rhot = binaryread(file1,idm,jdm,ijdm,depthid);

Rho = Rhot(Y1:Y2,X1:X2);
F   = Ft(Y1:Y2,X1:X2);

 [ch] = figure();
% orient landscape;

 maxF   = quantile(F(~isnan(F)),.9);
 minF   = quantile(F(~isnan(F)),.1);


%%%%%%%%%%%%%%%%%%%%%% F
 [p1,p1] = contourf(lon,lat,F,50);
% p1 = imagesc(lon,lat,F);
 axis xy;
 set(p1,'LineStyle','none');
 hold on;
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)

 caxis([minF maxF]);

 [p2,p2] = contour(lon,lat,Rho);
 set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
 th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
 title('F')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 colorbar;
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/F_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/F_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
