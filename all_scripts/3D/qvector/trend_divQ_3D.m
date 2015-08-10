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

for region = 1:1

[X1,X2,Y1,Y2,R] = regions(5);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

ids = X2-X1+1; % of region A
jds = Y2-Y1+1;
ijds = ids*jds;

QT = zeros(jds,ids,kl);

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

if (arch == 1)
 file1  = strcat('./output/high-res/qvectorx_h_02_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('./output/high-res/qvectory_h_02_archv.',lyear,'_',lday,'_00.a')
else
 file1  = strcat('./output/low-res/qvectorx_l_02_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('./output/low-res/qvectory_l_02_archv.',lyear,'_',lday,'_00.a')
end

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

qxt   = binaryread(file1,idm,jdm,ijdm,did);
qyt   = binaryread(file2,idm,jdm,ijdm,did);
%qvectort(abs(qvectort) > 1000) = quantile(qvectort(~isnan(qvectort)),0.5);

qx = qxt(Y1:Y2,X1:X2);
qy = qyt(Y1:Y2,X1:X2);

qxx = cdxy(qx,pscx,0);
qyy = cdxy(qy,pscy,1);

qc(:,:,did) = abs(qxx+qyy);

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

QMT(time) = avg_3D(qc,pscx,pscy,fm,depth)

end % end time

 hold on;

% p1 = plot(dayi:dayf,QMP);
% set(p1,'Color','k','LineWidth',1.2)
% p2 = plot(dayi:dayf,QMN);
% set(p2,'Color','b','LineWidth',1.2)
 p3 = plot(dayi:dayf,QMT);
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

 ylabel('|\nabla \cdot Q|','FontSize',18)
 xlabel('Time (days)','FontSize',18)

 set(gca,'XTick', 1:6:itime);
 set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

end % end arch

 label = strcat('./plot/divQ_',R,'_3D.eps')

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % end region
