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

maxr = 1;
minr = -1;
maxtr = -10;
mintr = 10;

N = 22;

for region = 1:4

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 1:1

for time  = 1:49

day   = textread('../../archivesDay');
year  = textread('../../archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:4

depth = readline('../layersDepth_4',did);
depthid = str2num(readline('../layersDepthID_4',did));
depth


if (arch == 1)
 file1   = strcat('./output/high-res/qvectorx_h_016_archv.',lyear,'_',lday,'_00.a');
 file2   = strcat('./output/high-res/qvectory_h_016_archv.',lyear,'_',lday,'_00.a');
 file3  = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
else
 file1   = strcat('./output/low-res/qvectorx_l_016_archv.',lyear,'_',lday,'_00.a');
 file2   = strcat('./output/low-res/qvectory_l_016_archv.',lyear,'_',lday,'_00.a');
 file3  = strcat('../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
end

Qxt = binaryread(file1,idm,jdm,ijdm,depthid);
Qyt = binaryread(file2,idm,jdm,ijdm,depthid);
Rhot   = binaryread(file3,idm,jdm,ijdm,depthid);

Qx    = Qxt(Y1:Y2,X1:X2);
Qy    = Qyt(Y1:Y2,X1:X2);
Rho   = Rhot(Y1:Y2,X1:X2);


 [ch] = figure();
% orient landscape;

% maxqvector   = quantile(qvector(~isnan(qvector)),.99);
% minqvector   = quantile(qvector(~isnan(qvector)),.01);

%%%%%%%%%%%%%%%%%%%%%% qvector
% [p1,p1] = contourf(lon,lat,qvector,50);

stp = 3;

Qx = Qx(1:stp:end,1:stp:end);
Qy = Qy(1:stp:end,1:stp:end);
lonq = lon(1:stp:end,1:stp:end);
latq = lat(1:stp:end,1:stp:end);


 p1 = imagesc(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
 title('qvector')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 colorbar;
 axis image

 hold on;

 p2 = quiver(lonq,latq,Qx,Qy,10);
 set(p2,'Color','k')
 axis xy;
% set(p1,'LineStyle','none');
% caxis([minqvector maxqvector]);
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
% colormap('Autumn');

if (arch == 1)
 label = strcat('./plot/high-res/qvector_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/qvector_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
