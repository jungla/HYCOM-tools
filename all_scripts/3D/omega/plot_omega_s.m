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

X1 = 590 
X2 = 720 
Y1 = 176 
Y2 = 267

x1 = X1 - 472
x2 = X2 - 472
y1 = Y1 - 80
y2 = Y2 - 80

R = 'As'

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

for did =1:2
% only the first 10 depths are defined in omega.

depth = readline('../layersDepth_2_03',did);
depthid = str2num(readline('../layersDepthID_2_03',did));
depth

if (arch == 1)
 file0   = strcat('./output/high-res/O_a_h_',lyear,'_',lday,'_00.a');
% file1   = strcat('./output/high-res/O_g_h_',lyear,'_',lday,'_00.a');
% file2   = strcat('./output/high-res/Bf_h_016_archv.',lyear,'_',lday,'_00.a');
% file3   = strcat('./output/high-res/G_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file0   = strcat('./output/low-res/O_a_l_',lyear,'_',lday,'_00.a');
% file1   = strcat('./output/low-res/O_g_l_',lyear,'_',lday,'_00.a');
% file2   = strcat('./output/low-res/Bf_l_016_archv.',lyear,'_',lday,'_00.a');
% file3   = strcat('./output/low-res/G_l_016_archv.',lyear,'_',lday,'_00.a');
end

xc = 1;
yc = 1;

ids = 800-472+1;
jds = 272-80+1;
ijds = ids*jds;

Oat = binaryread(file0,ids,jds,ijds,depthid);
%Ogt = binaryread(file1,ids,jds,ijds,depthid);

%Og = Ogt(y1:y2,x1:x2);
Oa = Oat(y1:y2,x1:x2);


if time == 2
 minoa = -2*10e-5
 maxoa =  2*10e-5
else
 maxoa   = quantile(Oa(~isnan(Oa)),.99);
 minoa   = quantile(Oa(~isnan(Oa)),.01);
end


 minoa = -1.5e-4
 maxoa =  1.5e-4

% maxog   = quantile(Og(~isnan(Og)),.99);
% minog   = quantile(Og(~isnan(Og)),.01);
% maxBf   = quantile(Bf(~isnan(Bf)),.99);
% minBf   = quantile(Bf(~isnan(Bf)),.01);
% maxG   = quantile(G(~isnan(G)),.95);
% minG   = quantile(G(~isnan(G)),.05);

%%%%%%%%%%%%%%%%%%%%%% omega
% [p1,p1] = contourf(lon,lat,omega,50);
% subplot(2,2,1), imagesc(lon,lat,Oa);

 [ch] = figure();
 [p1,p1] = contourf(lon,lat,Oa,50);
% imagesc(lon,lat,Oa);
 axis xy;
 set(p1,'LineStyle','none');
 colorbar;
 hold on;
 caxis([minoa maxoa]);
% load('OWColorMap.mat','mycmap')
% set(ch,'Colormap',mycmap)
 title('\omega','FontSize',18)
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/Oa_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/Oa_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch
