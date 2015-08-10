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

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 1:2

for time  = 1:2

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_2');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did = 1:4

depth = readline('/tamay/mensa/hycom/scripts/3D/layersDepth_4',did);
depthid = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_4_02',did));

depth

if (arch == 1)
 filew = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_02_h_070_archv.',lyear,'_',lday,'_00_w.a');
 filewo = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zw.A');
 filer = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_02_h_070_archv.',lyear,'_',lday,'_00_r.a');
 filero = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zr.A');
else
 filew = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_02_l_070_archv.',lyear,'_',lday,'_00_w.a');
 filewo = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zw.A');
 filer = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_02_l_070_archv.',lyear,'_',lday,'_00_r.a');
 filero = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zr.A');
end

fw = binaryread(filew,ids,jds,ijds,depthid);
fr = binaryread(filer,ids,jds,ijds,depthid);
ftwo = binaryread(filewo,idm,jdm,ijdm,depthid);
ftro = binaryread(filero,idm,jdm,ijdm,depthid);

fwo  = ftwo(Y1:Y2,X1:X2);
fro  = ftro(Y1:Y2,X1:X2);

fro = fro + 1000;

fwr = fwo - fw;
frr = fro - fr;

%filter  = smoothc(filtert(Y1:Y2,X1:X2),xc,yc);


%%%%%%%%%%%%%%%%%%%%%% filter PK

 PKr = -9.81.*fwr.*frr./1000; 

 maxPKr  = quantile(PKr(~isnan(PKr)),.99);
 minPKr  = quantile(PKr(~isnan(PKr)),.01);

 [ch] = figure();
 imagesc(PKr);
 axis xy;
 caxis([minPKr maxPKr]);
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)
 title(strcat('EBF ',num2str(mean(PKr(~isnan(PKr))))),'FontSize',18)
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
