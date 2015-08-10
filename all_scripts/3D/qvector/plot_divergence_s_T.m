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

[X1,X2,Y1,Y2,R] = regions_s(region);

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
 file1   = strcat('./output/high-res/qvectorx_h_016_archv.',lyear,'_',lday,'_00.a');
 file2   = strcat('./output/high-res/qvectory_h_016_archv.',lyear,'_',lday,'_00.a');
 file3  = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
 file4  = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zu.A');
 file5  = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zv.A');
else
 file1   = strcat('./output/low-res/qvectorx_l_016_archv.',lyear,'_',lday,'_00.a');
 file2   = strcat('./output/low-res/qvectory_l_016_archv.',lyear,'_',lday,'_00.a');
 file3  = strcat('../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
 file4  = strcat('../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zu.A');
 file5  = strcat('../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zv.A');
end

Qxt = binaryread(file1,idm,jdm,ijdm,depthid);
Qyt = binaryread(file2,idm,jdm,ijdm,depthid);
Rhot   = binaryread(file3,idm,jdm,ijdm,depthid);
ut = binaryread(file4,idm,jdm,ijdm,depthid);
vt = binaryread(file5,idm,jdm,ijdm,depthid);

Qx    = Qxt(Y1:Y2,X1:X2);
Qy    = Qyt(Y1:Y2,X1:X2);
Rho   = Rhot(Y1:Y2,X1:X2);
u    = ut(Y1:Y2,X1:X2);
v    = vt(Y1:Y2,X1:X2);



 [ch] = figure();
% orient landscape;

%%%%%%%%%%%%%%%%%%%%%% qvector
% [p1,p1] = contourf(lon,lat,qvector,50);

stp = 3;

Qx = Qx(1:stp:end,1:stp:end);
Qy = Qy(1:stp:end,1:stp:end);

 div = divergence(lon,lat,u,v);

 p1 = imagesc(lon,lat,div);
 title('divergence')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 colorbar;
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
 axis image
 caxis([min(min(div)) max(max(div))]);

 hold on;

 p3 = contour(lon,lat,Rho);
 axis xy;
% set(p1,'LineStyle','none');
% caxis([minqvector maxqvector]);
% colormap('Autumn');

if (arch == 1)
 label = strcat('./plot/high-res/divergence_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/divergence_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
