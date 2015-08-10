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

pscx = tpscx(Y1S:Y2S,X1S:X2S);
pscy = tpscy(Y1S:Y2S,X1S:X2S);

X1 = X1S - X1A;
X2 = X2S - X1A;
Y1 = Y1S - Y1A;
Y2 = Y2S - Y1A;

ids = X2A-X1A+1; % of region A
jds = Y2A-Y1A+1;
ijds = ids*jds;

lon = tlon(1,X1S:X2S); % of subregion As
lat = tlat(Y1S:Y2S,1);

for did = 2:2

depth = readline('/tamay/mensa/hycom/scripts/3D/layersDepth_4',did);
depthid_ML = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_ML_3',did));

[ch] = figure();

for arch = 1:2

itime = 0;

dayi  = 1;
dayf  = 49;

for time  = dayi:1:dayf

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

itime = itime + 1;
timeBar(itime) = day(time);

if (arch == 1)
 filew = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_016_archv.',lyear,'_',lday,'_00_w.a');
 filewo = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zw.a');
 filer = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_016_archv.',lyear,'_',lday,'_00_r.a');
 filero = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zr.a');
else
 filew = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_w.a');
 filewo = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/archv.',lyear,'_',lday,'_00_3zw.a');
 filer = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_r.a');
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

PKr = fwr .* frr .* 9.81 ./ 1000; %nanmean(nanmean(fro)); 

m = 0;
t = 0;
T = 0;
tt = 0;
mm = 0;

for i = 1:jds
 for j = 1:ids

  if(~isnan(PKr(i,j)))
   tt = tt + pscx(i,j)*pscy(i,j);

   if(PKr(i,j) < 0)
    t = t + abs(PKr(i,j)*(pscx(i,j)*pscy(i,j)));
   elseif(PKr(i,j) > 0)
    m = m + PKr(i,j)*(pscx(i,j)*pscy(i,j));
   end
    T = T + PKr(i,j)*(pscx(i,j)*pscy(i,j));
  end

 end
end

 if(tt > 0)
 PKMP(itime) = t/tt
 PKMN(itime) = m/tt
 PKMT(itime) = T/tt
 end

end % time

 hold on;

 p1 = plot(dayi:dayf,PKMP);
 set(p1,'Color','k','LineWidth',1.2)
 p2 = plot(dayi:dayf,PKMN);
 set(p2,'Color','b','LineWidth',1.2)
 p3 = plot(dayi:dayf,PKMT);
 set(p3,'Color',[0.2 0.2 0.2],'LineWidth',1.2)

if (arch == 1)
 set(p1,'LineStyle','-')
 set(p2,'LineStyle','-')
 set(p3,'LineStyle','-')
else
 set(p1,'LineStyle','--')
 set(p2,'LineStyle','--')
 set(p3,'LineStyle','--')
end

 ylabel('PK','FontSize',18)
 xlabel('Time (days)','FontSize',18)

 set(gca,'XTick', 1:3:itime);
 set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

end % end arch

 label = strcat('./plot/PKr_',R,'.eps')

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end region
