clear all;

gridbfid=fopen('/tamay/mensa/hycom/scripts/topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
ijdm = idm*jdm;

file = '/tamay/mensa/hycom/scripts/topo0.02/regional.grid.a';

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

for region = 1:1

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 1:1

for time  = 2:2

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_2');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:4

depth = readline('/tamay/mensa/hycom/scripts/3D/layersDepth_4',did);
depthid = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_4',did));
depth


if (arch == 1)
 file   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/high-res/gwind_h_016_archv.',lyear,'_',lday,'_00.a');
 filea   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/high-res/gwind_h_016A_archv.',lyear,'_',lday,'_00.a');
 fileb   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/high-res/gwind_h_016B_archv.',lyear,'_',lday,'_00.a');
 filec   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/high-res/gwind_h_016C_archv.',lyear,'_',lday,'_00.a');
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/high-res/gwind_h_016nu_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
else
 file   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/low-res/gwind_l_016_archv.',lyear,'_',lday,'_00.a');
 filea   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/low-res/gwind_l_016A_archv.',lyear,'_',lday,'_00.a');
 fileb   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/low-res/gwind_l_016B_archv.',lyear,'_',lday,'_00.a');
 filec   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/low-res/gwind_l_016C_archv.',lyear,'_',lday,'_00.a');
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/gwind/output/low-res/gwind_l_016nu_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
end

xc = 1;
yc = 1;

gwindt = binaryread(file,idm,jdm,ijdm,depthid);
gwindtA = binaryread(filea,idm,jdm,ijdm,depthid);
gwindtB = binaryread(fileb,idm,jdm,ijdm,depthid);
gwindtC = binaryread(filec,idm,jdm,ijdm,depthid);
gwindtN = binaryread(fileu,idm,jdm,ijdm,depthid);
Rhot   = binaryread(file1,idm,jdm,ijdm,depthid);

Rho    = Rhot(Y1:Y2,X1:X2);
gwind  = gwindt(Y1:Y2,X1:X2);
gwindA  = gwindtA(Y1:Y2,X1:X2);
gwindB  = gwindtB(Y1:Y2,X1:X2);
gwindC  = gwindtC(Y1:Y2,X1:X2);
gwindN  = gwindtN(Y1:Y2,X1:X2);
%gwind  = smoothc(gwindt(Y1:Y2,X1:X2),xc,yc);


 [ch] = figure();
 %orient landscape;

% maxgwind   = quantile(gwind(~isnan(gwind)),.9);
% mingwind   = quantile(gwind(~isnan(gwind)),.1);
 maxgwind  = 1;
 mingwind  = 0;

%%%%%%%%%%%%%%%%%%%%%% gwind
% imagesc(lon,lat,gwind);
 subplot(5,1,1), imagesc(lon,lat,gwind);
 axis xy;
 colorbar;
 caxis([mingwind maxgwind]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

 subplot(5,1,2), imagesc(lon,lat,gwindA);
 axis xy;
 colorbar;
 caxis([quantile(gwindA(~isnan(gwindA)),.1) quantile(gwindA(~isnan(gwindA)),.9)]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

 subplot(5,1,3), imagesc(lon,lat,gwindB);
 axis xy;
 colorbar;
 caxis([quantile(gwindB(~isnan(gwindB)),.1) quantile(gwindB(~isnan(gwindB)),.9)]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

 subplot(5,1,4), imagesc(lon,lat,gwindC);
 axis xy;
 colorbar;
 caxis([quantile(gwindC(~isnan(gwindC)),.1) quantile(gwindC(~isnan(gwindC)),.9)]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

 subplot(5,1,5), imagesc(lon,lat,gwindN);
 axis xy;
 colorbar;
 caxis([quantile(gwindN(~isnan(gwindN)),.1) quantile(gwindN(~isnan(gwindN)),.9)]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image



if (arch == 1)
 label = strcat('./plot/high-res/gwind_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/gwind_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
