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

for region = 1:1

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

for did = 1:2

depth = readline('../layersDepth_4',did);
depthid = str2num(readline('../layersDepthID_4_02',did));
depth

if (arch == 1)
 file1  = strcat('../../../GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('../../../GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zw.A');
else
 file1  = strcat('../../../GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('../../../GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zw.A');
end

Rhot = binaryread(file1,idm,jdm,ijdm,depthid);
wt   = binaryread(file2,idm,jdm,ijdm,depthid);

w  = wt(Y1:Y2,X1:X2);
Rho = Rhot(Y1:Y2,X1:X2);

 [ch] = figure();
% orient landscape;


%%%%%%%%%%%%%%%%%%%%%% plot w


if did == 2
minw = -1.5*10^-3
maxw =  1.5*10^-3
else
minw = -5*10^-4
maxw =  5*10^-4
end

maxw = quantile(w(~isnan(w)),0.99)
minw = quantile(w(~isnan(w)),0.01)

maxw = quantile(w(~isnan(w)),1)
minw = quantile(w(~isnan(w)),0)

%minw = -2e-3
%maxw =  2e-3

ws = w./std(w(~isnan(w)));

%ws(abs(ws)<1) = NaN;

 [p0,p0] = contourf(lon,lat,w,50);
 set(p0,'LineStyle','none');
% hold on;
% [p1,p1] = contour(lon,lat,w,[5*10^-4 5*10^-4]);
% set(p1,'Color',[0 0 0],'LineStyle','-','ShowText','off'); 
% [p2,p2] = contour(lon,lat,w,[-5*10^-4 -5*10^-4]);
% set(p2,'Color',[0 0 0],'LineStyle',':','ShowText','off');
% [p1,p1] = contour(lon,lat,ws,[2 2]);
% p1 = imagesc(lon,lat,w);
 axis xy;
 caxis([minw maxw])
 caxis([-1.5*10^-3 1.5*10^-3])
% load('OWColorMap.mat','mycmap')
% set(ch,'Colormap',mycmap)
 colorbar;

% hold on;
% [p2,p2] = contour(lon,lat,Rho,'Color',[0.2 0.2 0.2]);
% set(p2,'ShowText','on','TextStep',get(p2,'LevelStep')*4);
% th = clabel(p2,p2,'Color',[0.2 0.2 0.2],'FontSize',7,'LabelSpacing',92);

 title('w','FontSize',18)
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)
 axis image


if (arch == 1)
 label = strcat('./plot/high-res/w_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/w_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
