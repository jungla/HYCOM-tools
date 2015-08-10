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
dayf = 99;  %
dstep = 1;   %

maxr = 1;
minr = -1;
maxtr = -10;
mintr = 10;

kl = 41;

for region = 1:1

[X1,X2,Y1,Y2,R] = regions(5);

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;


pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

PKT = zeros(jds,ids,kl);

lon = tlon(1,X1:X2); % of subregion As
lat = tlat(Y1:Y2,1);

[ch] = figure();

for arch = 1:2

itime = 0;

dayi  = 1;
dayf  = 99;

for time  = dayi:1:dayf

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_all_02');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_all_02');

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
 depth_1 = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_all_02',did));
 depth_2 = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_all_02',did+1));
 dz(did) = depth_2-depth_1;
 depth(did) = depth_1;
end
 depth(kl) = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_all_02',kl));

for did = 1:kl

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

xc = 1;
yc = 1;

fw = binaryread(filew,ids,jds,ijds,did);
fr = binaryread(filer,ids,jds,ijds,did);
fwot = binaryread(filewo,idm,jdm,ijdm,did);
frot = binaryread(filero,idm,jdm,ijdm,did);

fwo = fwot(Y1:Y2,X1:X2);
fro = frot(Y1:Y2,X1:X2);

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
fm = fmt(Y1:Y2,X1:X2)./9806;

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
 
    if(PKr(i,j,k) < 0)
     t = t + abs(PKr(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k));
    elseif(PKr(i,j,k) > 0)
     m = m + PKr(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
    end
     T = T + PKr(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
   end
  end
 end
end

 if(tt > 0)
 PKMP(itime) = t/tt
 PKMN(itime) = m/tt
 PKMT(itime) = T/tt
 end

end % end time

 hold on;

% p1 = plot(dayi:dayf,PKMP);
% set(p1,'Color','k','LineWidth',1.2)
% p2 = plot(dayi:dayf,PKMN);
% set(p2,'Color','b','LineWidth',1.2)
 p3 = plot(dayi:dayf,PKMT);

if (arch == 1)
 set(p3,'Color','k','LineWidth',1.2)
% set(p1,'LineStyle','-')
% set(p2,'LineStyle','-')
% set(p3,'LineStyle','-')
else
 set(p3,'Color','b','LineWidth',1.2)
% set(p1,'LineStyle','--')
% set(p2,'LineStyle','--')
% set(p3,'LineStyle','--')
end

 ylabel('PK','FontSize',18)
 xlabel('Time (days)','FontSize',18)

 set(gca,'XTick', 1:6:itime);
 set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

end % end arch

 label = strcat('./plot/PKr_',R,'.eps')

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % end region
