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

N = 22;


for region = 6:6

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 49;
dstep = 1;


[ch]= figure();

for arch = 1:1

for did = 1:1

depth   = readline('../../3D/layersDepth_2_03',did);
depthid = str2num(readline('../../3D/layersDepthID_2_03',did));

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;


clear wM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../../3D/archivesDay_all_03');
year  = textread('../../3D/archivesYear_all_03');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;

% x bar for plotting
timeBar(itime) = day(time);

arch
lday
lyear
depth

if (arch == 1)
 file1  = strcat('./output/high-res/O_a_h_',lyear,'_',lday,'_00.a');
 file2  = strcat('/tamay/mensa/hycom/GSa0.0x_ML/016_archv.',lyear,'_',lday,'_00_ML_3zr.A');
else
 file1  = strcat('./output/low-res/O_a_l_',lyear,'_',lday,'_00.a');
 file2  = strcat('/tamay/mensa/hycom/GSa0.0x_ML/archv.',lyear,'_',lday,'_00_ML_3zr.A');
end

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;

Oat = binaryread(file1,ids,jds,ijds,depthid);
Oat = abs(Oat);

OaM(itime) = avg_region(Oat,tpscx,tpscy,1,ids,1,jds,0);

end % day loop
end % day loop

end % depth loop
end % close archive high/low res loop


%close all;

%%% PK


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

for arch = 1:1

itime = 0;

dayi  = 1;
dayf  = 49;

for time  = dayi:1:dayf

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_all_03');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_all_03');

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
end

 hold on;

% p1 = plot(dayi:dayf,PKMP);
% set(p1,'Color','k','LineWidth',1.2)
% p2 = plot(dayi:dayf,PKMN);
% set(p2,'Color','b','LineWidth',1.2)

ch = figure();

[AX H1 H2] = plotyy(dayi:dayf,PKMT,dayi:dayf,OaM)
set(get(AX(1),'Ylabel'),'String','PK','fontsize',18)
set(get(AX(2),'Ylabel'),'String','Omega','fontsize',18)
set(AX(1),'ycolor','k')
set(AX(2),'ycolor','b')
set(H1,'Color','k')
set(H2,'Color','b')

axes(AX(1));
set(AX(1),'ylim',[-2e-8 4e-8]);
set(AX(1),'XTick', 1:3:itime);
set(AX(1),'FontSize',17);
set(AX(1),'XTickLabel',[])

axes(AX(2));
set(AX(2),'ylim',[-0.5e-5 1.5e-5]);
set(AX(2),'XTick', 1:3:itime);
set(AX(2),'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

xlabel('Time (days)','FontSize',18)

% title(strcat(['KE below 100km and KE below 10km vs Time (region ',R,', high-res)']),'fontsize',16);
 label = strcat('./plot/PKr_O_',R,'.eps')
% title(strcat(['KE below 100km and KE below 10km vs Time (region ',R,', low-res)']),'fontsize',16);

set(H1,'LineStyle','-','linewidth',2);
set(H2,'LineStyle','-','linewidth',2);

 print(ch,'-dpsc2',label)

end % end arch


 'saving...'
 print(ch,'-dpsc2',label)
 %close all;


