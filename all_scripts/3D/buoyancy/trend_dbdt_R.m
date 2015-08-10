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

maxr = 1;
minr = -1;
maxtr = -10;
mintr = 10;

kl = 27;

dayi  = 50;
dayf  = 99-1;
days = 1;

for region = 1:1

[X1A,X2A,Y1A,Y2A,R] = regions(5);
[X1S,X2S,Y1S,Y2S,R] = regions_s(region);

pscx = tpscx(Y1A:Y2A,X1A:X2A);
pscy = tpscy(Y1A:Y2A,X1A:X2A);

X1 = X1S - X1A;
X2 = X2S - X1A;
Y1 = Y1S - Y1A;
Y2 = Y2S - Y1A;

ids = X2A-X1A+1; % of region A
jds = Y2A-Y1A+1;
ijds = ids*jds;


lon = tlon(1,X1S:X2S); % of subregion As
lat = tlat(Y1S:Y2S,1);

for deltaid = 1:4

delta = readline('/tamay/mensa/hycom/scripts/3D/delta_filt',deltaid);

BT = zeros(jds,ids,kl);

[ch] = figure();
hold on;

for arch = 1:2

itime = 0;


dz    = zeros(kl-1,1);
depth = zeros(kl,1);
dz(1) = 0;

for did = 1:kl-1
 depth_1 = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_ML_27',did));
 depth_2 = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_ML_27',did+1));
 dz(did) = depth_2-depth_1;
 depth(did) = depth_1;
end
 depth(kl) = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_ML_27',kl));

for time  = dayi:days:dayf

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_ML');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_ML');

lday0  = digit(day(time),3);
lyear0 = digit(year(time),4);

lday1  = digit(day(time+1),3);
lyear1 = digit(year(time+1),4);


lday0
lyear0
lday1;
lyear1;

itime = itime + 1;
timeBar(itime) = day(time);

for did = 1:kl

depthid_ML = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_ML_27',did));
depth_ML = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_ML_27',did));

if (arch == 1)
 filew0 = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_h_',delta,'_archv.',lyear0,'_',lday0,'_00_w.a');
 filewo0 = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear0,'_',lday0,'_00_3zw.a');
 filer0 = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_h_',delta,'_archv.',lyear0,'_',lday0,'_00_r.a');
 filero0 = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear0,'_',lday0,'_00_3zr.a');
 filew1 = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_h_',delta,'_archv.',lyear1,'_',lday1,'_00_w.a');
 filewo1 = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear1,'_',lday1,'_00_3zw.a');
 filer1 = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_h_',delta,'_archv.',lyear1,'_',lday1,'_00_r.a');
 filero1 = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear1,'_',lday1,'_00_3zr.a');

else
 filew0 = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_l_',delta,'_archv.',lyear0,'_',lday0,'_00_w.a');
 filewo0 = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/archv.',lyear0,'_',lday0,'_00_3zw.a');
 filer0 = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_l_',delta,'_archv.',lyear0,'_',lday0,'_00_r.a');
 filero0 = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/archv.',lyear0,'_',lday0,'_00_3zr.a');
 filew1 = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_l_',delta,'_archv.',lyear1,'_',lday1,'_00_w.a');
 filewo1 = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/archv.',lyear1,'_',lday1,'_00_3zw.a');
 filer1 = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_l_',delta,'_archv.',lyear1,'_',lday1,'_00_r.a');
 filero1 = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/archv.',lyear1,'_',lday1,'_00_3zr.a');
end

xc = 1;
yc = 1;

fw0 = binaryread(filew0,ids,jds,ijds,depthid_ML);
fr0 = binaryread(filer0,ids,jds,ijds,depthid_ML);
fwo0 = binaryread(filewo0,ids,jds,ijds,depthid_ML);
fro0 = binaryread(filero0,ids,jds,ijds,depthid_ML);
fw1 = binaryread(filew1,ids,jds,ijds,depthid_ML);
fr1 = binaryread(filer1,ids,jds,ijds,depthid_ML);
fwo1 = binaryread(filewo1,ids,jds,ijds,depthid_ML);
fro1 = binaryread(filero1,ids,jds,ijds,depthid_ML);

fro0 = fro0 + 1000;
fro1 = fro1 + 1000;

fwr0= fwo0- fw0;
frr0= fro0- fr0;
fwr1= fwo1- fw1;
frr1= fro1- fr1;

B0(:,:,did) = - fro0 .* 9.81 ./ 1000; 
B1(:,:,did) = - fro1 .* 9.81 ./ 1000; 

PKr(:,:,did) = - fwr0 .* frr0 .* 9.81 ./ 1000;

end % fill depths

%'depths read'

% build mixed layer depth matrix

MLT = ones(jds,ids,kl);

if (arch == 1)
 filem0 = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear0,'_',lday0,'_00.a');
 filem1 = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear1,'_',lday1,'_00.a');
else
 filem0 = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear0,'_',lday0,'_00.a');
 filem1 = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear1,'_',lday1,'_00.a');
end

fmt0 = hycomread(filem0,idm,jdm,ijdm,6);
fmt1 = hycomread(filem1,idm,jdm,ijdm,6);
fm0 = fmt0(Y1A:Y2A,X1A:X2A)./9806;
fm1 = fmt1(Y1A:Y2A,X1A:X2A)./9806;

ML = (avg_region(fm0,pscx,pscy,1,ids,1,jds,0)+avg_region(fm1,pscx,pscy,1,ids,1,jds,0))/2;

if arch == 1
 MLDh(itime) = ML;
else
 MLDl(itime) = ML;
end

T = 0;
B = 0;
tt = 0;
mm = 0;

Bd = zeros(kl,1);

dT = ((str2num(lday1) - str2num(lday0))*86400);

for k = 1:kl
 B0a = avg_region(B0(:,:,k),pscx,pscy,1,ids,1,jds,0);
 B1a = avg_region(B1(:,:,k),pscx,pscy,1,ids,1,jds,0);
 dB(k) = (B1a-B0a);
end

dBdT = dB./dT;

if arch == 1
dBdTMh(itime) = mean(dBdT(depth<ML));
else
dBdTMl(itime) = mean(dBdT(depth<ML));
end

dBM(itime) = mean(dB(depth<ML));

for i = 1:jds
 for j = 1:ids
  for k = 1:kl-1
   if(~isnan(PKr(i,j,k)) && depth(k) <= fm0(i,j))
     tt = tt + pscx(i,j)*pscy(i,j)*dz(k);
     T = T + PKr(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
   end
  end
 end
end

if(tt > 0)
 if arch == 1
  PKh(itime) = T/tt;
 else
  PKl(itime) = T/tt;
 end 
end

end % end time
end % end arch

PKHh = PKh./MLDh;
dHh =  PKh./dBdTMh;
PKHl = PKl./MLDl;
dHl =  PKl./dBdTMl;

PKH = (PKh-PKl)./(MLDh-MLDl);


p1 = plot(dayi:days:dayf,dBdTMh);
hold on
p2 = plot(dayi:days:dayf,PKH);
set(p1,'Color',[0.8 0.8 0.8],'LineWidth',1.2)
set(p2,'Color','k','LineWidth',1.2)

if arch == 1
% set(p1,'LineStyle','-')
% label = strcat('./plot/dbdt_',R,'_h.eps')
else
% set(p1,'LineStyle','--')
% label = strcat('./plot/dbdt_',R,'_l.eps')
end

ylim([-0.4e-8 0.4e-8])

%label = strcat('./plot/dbdt_',R,'.eps')
label = strcat('./plot/PKH_',delta,'.eps')
'saving...'
print(ch,'-dpsc2',label)
close all;


%[ch] = figure();
% p1 = plot(dayi:days:dayf,dH);
% set(p1,'Color',[0.8 0.8 0.8],'LineWidth',1.2)
%% ylabel('B','FontSize',18)
% xlabel('Time','FontSize',18)
%% set(gca,'XTick', 1:3:itime);
%% set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)
%if arch == 1
% label = strcat('./plot/dh_',R,'_h.eps')
%else
% label = strcat('./plot/dh_',R,'_l.eps')
%end
%'saving...'
%print(ch,'-dpsc2',label)
%close all;



end % end delta 
end % end region
