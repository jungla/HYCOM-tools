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


tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

maxr = 1;
minr = -1;
maxtr = -10;
mintr = 10;

dayi  = 25; % (498-365)/5
dayf  = 99;
days = 1;

kl = 41;

for region = 5:5
[X1,X2,Y1,Y2,R] = regions(region);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;

PKT = zeros(jds,ids,kl);

for arch = 1:1

dz    = zeros(kl-1,1);
depth = zeros(kl,1);
dz(1) = 0;

for did = 1:kl-1
 depth_1 = str2num(readline('../layersDepth_all_02',did));
 depth_2 = str2num(readline('../layersDepth_all_02',did+1));
 dz(did) = depth_2-depth_1;
 depth(did) = depth_1;
end
 depth(kl) = str2num(readline('../layersDepth_all_02',kl));

for deltaid = 3:3

itime = 0;
delta = readline('/tamay/mensa/hycom/scripts/3D/delta_filt',deltaid);

for time  = dayi:days:dayf

day   = textread('../archivesDay_all_02');
year  = textread('../archivesYear_all_02');


lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

itime = itime + 1;
timeBar(itime) = day(time);

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

fw = binaryread(filew,ids,jds,ijds,did);
fr = binaryread(filer,ids,jds,ijds,did);
ftwo = binaryread(filewo,idm,jdm,ijdm,did);
ftro = binaryread(filero,idm,jdm,ijdm,did);

fwo  = ftwo(Y1:Y2,X1:X2);
fro  = ftro(Y1:Y2,X1:X2);

fro = fro + 1000;

fwr = fwo - fw;
frr = fro - fr;

%%%%%%%%%%%%%%%%%%%%%% filter PK

PKr(:,:,did) = - fwr .* frr .* 9.81 ./ 1000; 

PKf(:,:,did) = smooth2(fr,2); 

[bx,by] = gradient(PKf(:,:,did));
PKf(:,:,did) = sqrt(bx.^2+by.^2);

end % fill depths

%'depths read'

% build mixed layer depth matrix

if (arch == 1)
 filem = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
else
 filem = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
end

fmt = hycomread(filem,idm,jdm,ijdm,6);
fm = fmt(Y1:Y2,X1:X2)./9806;

ML(itime) = avg_region(fm,pscx,pscy,1,ids,1,jds,0);

T = 0;
B = 0;
tt = 0;
mm = 0;

for i = 1:jds
 for j = 1:ids
  for k = 1:kl-1
   if(~isnan(PKr(i,j,k)) && depth(k) <= fm(i,j))
     tt = tt + pscx(i,j)*pscy(i,j)*dz(k);
     T = T + PKr(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
   end
   if(~isnan(PKf(i,j,k)) && depth(k) <= fm(i,j))
     mm = mm + pscx(i,j)*pscy(i,j)*dz(k);
     B = B + PKf(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
   end
  end
 end
end

 if(tt > 0)
 MT(itime) = T/tt;
 end

 if(mm > 0)
 MB(itime) = B/mm;
 end
end % end time

MBML = (MB.*ML).^2;
MBMLMT = (MBML./MT);
MTn = MT./max(MT);
MBn = MB./max(MB);
MLn = ML./max(ML);
MBMLMTn = MBMLMT./max(MBMLMT);
MBMLn = MBML./max(MBML);

[ch] = figure();

 hold on;

% p01 = plot(dayi:dayf,MP);
% set(p01,'Color','k','LineWidth',1.2)
% p02 = plot(dayi:dayf,MN);
% set(p02,'Color','b','LineWidth',1.2)

 p1 = plot(dayi:days:dayf,MTn);
 set(p1,'Color','r','LineWidth',1.2)
 p2 = plot(dayi:days:dayf,MBn);
 set(p2,'Color',[0.5 0.5 0.5],'LineWidth',1.2)
 p3 = plot(dayi:days:dayf,MLn);
 set(p3,'Color',[0.5 0.5 0.5],'LineWidth',1.2,'LineStyle','--')
 p4 = plot(dayi:days:dayf,MBMLn);
 set(p4,'Color','b','LineWidth',1.2)

% p5 = plot(dayi:days:dayf,MBMLMTn);
% set(p5,'Color','r','LineWidth',1)

%if (arch == 1)
% set(p1,'LineStyle','-')
% set(p2,'LineStyle','-')
% set(p3,'LineStyle','-')
% set(p4,'LineStyle','-')
% set(p5,'LineStyle','-')
%else
% set(p1,'LineStyle','--')
% set(p2,'LineStyle','--')
% set(p3,'LineStyle','--')
% set(p4,'LineStyle','--')
% set(p5,'LineStyle','--')
%end

% ylabel('PK','FontSize',18)
 xlabel('Time','FontSize',18)

 set(gca,'XTick', 1:6:itime);
 set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

if arch == 1
 label = strcat('./plot/PKMLB_',delta,'_',R,'_h.eps')
else
 label = strcat('./plot/PKMLB_',delta,'_',R,'_l.eps')
end

'saving...'
print(ch,'-dpsc2',label)
close all;

%[ch] = figure();
%scatter(log(MBML),log(MT));
%p = polyfit(log(MBML),log(MT),1)

%if arch == 1
% label = strcat('./plot/MLB_',delta,'_',R,'_h.eps')
%else
% label = strcat('./plot/MLB_',delta,'_',R,'_l.eps')
%end

%'saving...'
%print(ch,'-dpsc2',label)
%close all;







% compute cross correlation

temp1 = zeros(itime,1);

for day = 1:itime

% PK and MLD
temp1(1:end-day+1) = MLn(day:end);
temp1(end-day+1:end) = MLn(1:day);
r = corrcoef(MTn,temp1,'rows','pairwise');
PKcML(day) = r(1,2);

% PK and nableb
temp1(1:end-day+1) = MBn(day:end);
temp1(end-day+1:end) = MBn(1:day);
r = corrcoef(MTn,temp1,'rows','pairwise');
PKcB(day) = r(1,2);

% PK and nableb*MLD
temp1(1:end-day+1) = MBMLn(day:end);
temp1(end-day+1:end) = MBMLn(1:day);
r = corrcoef(MTn,temp1,'rows','pairwise');
PKcMLB(day) = r(1,2);

end % end correlation loop

fig = figure();
p1 = plot(1:itime,PKcML,'-k',1:itime,PKcB,'--k',1:itime,PKcMLB,':k')
set(p1,'LineWidth',2.5);
ylabel('r','FontSize',30)
xlabel('Time Lag','FontSize',30)
set(gca,'XTick', 0:60:itime);
set(gca,'XTickLabel',0:60:itime,'FontSize',24);
ylim([-1 +1]);
xlim([0 itime]);

if arch == 1
 label = strcat('./plot/trend_corr_PK_BMLD_',delta,'_',R,'_h.eps')
else
 label = strcat('./plot/trend_corr_PK_BMLD_',delta,'_',R,'_l.eps')
end

print(fig,'-dpsc2',label)
close all;

end % end delta
end % end arch
end % end region
