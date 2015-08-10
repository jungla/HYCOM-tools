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

[X1A,X2A,Y1A,Y2A,R] = regions(5);
[X1S,X2S,Y1S,Y2S,R] = regions_s(region);

X1 = X1S - X1A;
X2 = X2S - X1A;
Y1 = Y1S - Y1A;
Y2 = Y2S - Y1A;

ids = X2A-X1A+1; % of region A
jds = Y2A-Y1A+1;
ijds = ids*jds;

lon = tlon(1,X1S:X2S); % of subregion As
lat = tlat(Y1S:Y2S,1);

for arch = 1:2

for time  = 1:2

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_2');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did = 1:2

depth = readline('/tamay/mensa/hycom/scripts/3D/layersDepth_4',did);

depthid_ML = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_ML_3',did));

depth


if (arch == 1)
 filew = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_h_070_archv.',lyear,'_',lday,'_00_w.a');
 filewo = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zw.a');
 filer = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_h_070_archv.',lyear,'_',lday,'_00_r.a');
 filero = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zr.a');
else
 filew = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_l_070_archv.',lyear,'_',lday,'_00_w.a');
 filewo = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/archv.',lyear,'_',lday,'_00_3zw.a');
 filer = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_l_070_archv.',lyear,'_',lday,'_00_r.a');
 filero = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/archv.',lyear,'_',lday,'_00_3zr.a');
end

xc = 1;
yc = 1;

ftw = binaryread(filew,ids,jds,ijds,depthid_ML);
ftr = binaryread(filer,ids,jds,ijds,depthid_ML);
ftwo = binaryread(filewo,ids,jds,ijds,depthid_ML);
ftro = binaryread(filero,ids,jds,ijds,depthid_ML);

fwo  = ftwo(Y1:Y2,X1:X2);
fro  = ftro(Y1:Y2,X1:X2);

fw  = ftw(Y1:Y2,X1:X2);
fr  = ftr(Y1:Y2,X1:X2);

fro = fro + 1000;

fwr = fwo - fw;
frr = fro - fr;

%filter  = smoothc(filtert(Y1:Y2,X1:X2),xc,yc);


%%%%%%%%%%%%%%%%%%%%%% filter PK

 PKr = - fwr .* frr .* 9.81 ./ 1000; %nanmean(nanmean(fro)); 

 maxPKr  =  4e-7; %quantile(PKr(~isnan(PKr)),.99);
 minPKr  = -4e-7; %quantile(PKr(~isnan(PKr)),.01);

 [ch] = figure();
% imagesc(lon,lat,PKr);
 [p1,p1] = contourf(lon,lat,PKr,50);
 set(p1,'LineStyle','none');

 axis xy;
 caxis([minPKr maxPKr]);
 ylabel('Latitude','FontSize',24)
 xlabel('Longitude','FontSize',24)
 set(gca,'FontSize',24)
 cb = colorbar;
 set(cb, 'FontSize',24)
 title('w''b''','FontSize',24)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_PKr.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_PKr.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
