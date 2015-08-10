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

for time = 2:2

for arch  = 1:2

for region = 3:3 %1:2:5

[X1,X2,Y1,Y2,R] = regions_lcs(region+time,arch);

lon = tlon(1,X1:X2-1);
lat = tlat(Y1:Y2-1,1);

ids = X2-X1;
jds = Y2-Y1;
ijds = ids*jds;

for time  = 1:2

if arch == 1
 day   = textread('../../3D/archivesDay_2_h_lcs');
 year  = textread('../../3D/archivesYear_2_h_lcs');
else
 day   = textread('../../3D/archivesDay_2_l_lcs');
 year  = textread('../../3D/archivesYear_2_l_lcs');
end

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did = 1:2

depth = readline('../layersDepth_2_lcs',did);
depthid = str2num(readline('../layersDepthID_2_lcs',did));

if arch == 1
 file1  = strcat('../../../GSa0.0x_2m_1k/016_archv.',lyear,'_',lday,'_00_2m_',R,'_3zr.A');
 file2  = strcat('../../../GSa0.0x_2m_1k/016_archv.',lyear,'_',lday,'_00_2m_',R,'_3zw.A');
else
 file1  = strcat('../../../GSa0.0x_2m_1k/archv.',lyear,'_',lday,'_00_2m_',R,'_3zr.A');
 file2  = strcat('../../../GSa0.0x_2m_1k/archv.',lyear,'_',lday,'_00_2m_',R,'_3zw.A');
end

Rhot = binaryread(file1,ids,jds,ijds,depthid);
wt   = binaryread(file2,ids,jds,ijds,depthid);

w  = wt(:,:);
Rho = Rhot(:,:);
Rho(Rho < 1) = NaN;

 [ch] = figure();
% orient landscape;


%%%%%%%%%%%%%%%%%%%%%% plot w

maxw = quantile(w(~isnan(w)),0.99)
minw = quantile(w(~isnan(w)),0.01)

% [p1,p1] = contourf(lon,lat,w);
 p1 = imagesc(lon,lat,w);
 axis xy;
 caxis([minw maxw])
% caxis([-2.5*10^-4 2.5*10^-4])
% set(p1,'LineStyle','none');
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)

 hold on;

 [p2,p2] = contour(lon,lat,Rho,'Color',[0 0 0]);
 set(p2,'ShowText','on','TextStep',get(p2,'LevelStep')*4);
 th = clabel(p2,p2,'Color',[0 0 0],'FontSize',7,'LabelSpacing',92);

 ylabel('Latitude','FontSize',20)
 xlabel('Longitude','FontSize',20)
 set(gca,'FontSize',20)

 cb = colorbar;
 set(cb, 'FontSize',20)

 axis image
if arch == 1
 title(['w, HR (',depth,')'],'FontSize',21);
 label = strcat('./plot/high-res/w_',depth,'_',lyear,'_',lday,'_h_',R,'_lcs.eps')
else
 title(['w, LR (',depth,')'],'FontSize',21);
 label = strcat('./plot/low-res/w_',depth,'_',lyear,'_',lday,'_l_',R,'_lcs.eps')
end
 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end day
end % end day

end % end region
