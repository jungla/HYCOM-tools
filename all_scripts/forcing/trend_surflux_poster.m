clear all;
%%%% dimensions  
gridbfid=fopen('/tamay/mensa/hycom/scripts/topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '/tamay/mensa/hycom/scripts/topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

tplon = hycomread(file,idm,jdm,ijdm,18);
tplat = hycomread(file,idm,jdm,ijdm,13);


for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;%498-365;
dayf  = 498;
dstep = 1;

owml = figure;

for arch = 1:1

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;


clear fluxM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('/tamay/mensa/hycom/scripts/archivesDay_all');
year  = textread('/tamay/mensa/hycom/scripts/archivesYear_all');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;

% x bar for plotting
timeBar(itime) = day(time);

R
arch
lday
lyear

if (arch == 1)
 file  = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
else
 file  = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
end

fluxt  = hycomread(file,idm,jdm,ijdm,3);

flux = avg_region(fluxt,tpscx,tpscy,X1,X2,Y1,Y2,0)

fluxM(itime) = flux;

end % day loop

figure(owml);
p1 = plot(1:itime,fluxM)
set(p1,'LineWidth',2);

if(arch == 1)
set(p1,'Color','k')
else
set(p1,'Color','b')
end

ylabel('f_T','FontSize',18)
xlabel('Time (days)','FontSize',18)
%xlim([1 itime]);
%ylim([3 17]);
set(gca,'XTick', 1:30:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',18)

% anomalies

end % close archive high/low res loop

print(owml,'-dpsc2',strcat('./plot/trend_surflux_poster_',R,'.eps'))
close all
end  % region loop
