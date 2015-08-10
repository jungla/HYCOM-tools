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

kl = 27;

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

PKT = zeros(jds,ids,kl);

lon = tlon(1,X1S:X2S); % of subregion As
lat = tlat(Y1S:Y2S,1);

for deltaid = 2:2

delta = readline('/tamay/mensa/hycom/scripts/3D/delta_filt',deltaid);

[ch] = figure();

for arch = 2:2
PKr = zeros(jds,ids,kl);

itime = 0;

dayi  = 1;
dayf  = 99;

for time  = dayi:1:dayf

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_ML');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_ML');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

itime = itime + 1;
timeBar(itime) = day(time);

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

for did = 1:kl

depthid_ML = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_ML_27',did));
depth_ML = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_ML_27',did));

if (arch == 1)
 filew = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_h_',delta,'_archv.',lyear,'_',lday,'_00_w.a');
 filewo = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zw.a');
 filer = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_h_',delta,'_archv.',lyear,'_',lday,'_00_r.a');
 filero = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zr.a');
else
 filew = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_l_',delta,'_archv.',lyear,'_',lday,'_00_w.a');
 filewo = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/archv.',lyear,'_',lday,'_00_3zw.a');
 filer = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_l_',delta,'_archv.',lyear,'_',lday,'_00_r.a');
 filero = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/archv.',lyear,'_',lday,'_00_3zr.a');
end

xc = 1;
yc = 1;

fw = binaryread(filew,ids,jds,ijds,depthid_ML);
fr = binaryread(filer,ids,jds,ijds,depthid_ML);
fwo = binaryread(filewo,ids,jds,ijds,depthid_ML);
fro = binaryread(filero,ids,jds,ijds,depthid_ML);

fro = fro + 1000;

fwr = fwo - fw;
frr = fro - fr;

PKr(:,:,did) = - fwr .* frr .* 9.81 ./ 1000; 

end % fill depths

'depths read'

% build mixed layer depth matrix

MLT = ones(jds,ids,kl);

if (arch == 1)
 filem = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
else
 filem = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
end

fmt = hycomread(filem,idm,jdm,ijdm,6);
fm = fmt(Y1A:Y2A,X1A:X2A)./9806;

m = 0;
t = 0;
T = 0;
tt = 0;
mm = 0;

for i = 1:jds
 for j = 1:ids
  for k = 1:kl-1
   if(~isnan(PKr(i,j,k)) && depth(k) <= fm(i,j))
     tt = tt + pscx(i,j)*pscy(i,j)*dz(k);
 
%    if(PKr(i,j,k) < 0)
%     t = t + abs(PKr(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k));
%    elseif(PKr(i,j,k) > 0)
%     m = m + PKr(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
%    end
     T = T + PKr(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
   end
  end
 end
end

 if(tt > 0)
% PKMP(itime) = t/tt
% PKMN(itime) = m/tt
 PKMT(itime) = T/tt
 end

end % end time

 hold on;

% p1 = plot(dayi:dayf,PKMP);
% set(p1,'Color','k','LineWidth',1.2)
% p2 = plot(dayi:dayf,PKMN);
% set(p2,'Color','b','LineWidth',1.2)
 p3 = plot(dayi:dayf,PKMT);
 set(p3,'Color',[0.2 0.2 0.2],'LineWidth',1.2)

if (arch == 1)
% set(p1,'LineStyle','-')
% set(p2,'LineStyle','-')
 set(p3,'LineStyle','-')
else
% set(p1,'LineStyle','--')
% set(p2,'LineStyle','--')
 set(p3,'LineStyle','--')
end

 ylabel('PK','FontSize',18)
 xlabel('Time (days)','FontSize',18)

 set(gca,'XTick', 1:6:itime);
 set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

end % end arch

 label = strcat('./plot/PKr_',delta,'_',R,'.eps')

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % end delta 
end % end region
