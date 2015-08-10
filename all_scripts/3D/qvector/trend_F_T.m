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

tplon = hycomread(file,idm,jdm,ijdm,12);
tplat = hycomread(file,idm,jdm,ijdm,13);

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 99;
dstep = 1;

owml = figure;
owmla = figure;
owmld = figure;

for arch = 1:2

for did = 1:1

depth   = readline('../layersDepth_2',did);
depthid = str2num(readline('../layersDepthID_2',did));

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;
qvectorM = 0;

clear FM

for time  = dayi:dstep:dayf

day   = textread('../archivesDay');
year  = textread('../archivesYear');

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
depth

if (arch == 1)
 file1  = strcat('./output/high-res/F_h_016_archv.',lyear,'_',lday,'_23.a')
else
 file1  = strcat('./output/low-res/F_l_016_archv.',lyear,'_',lday,'_23.a')
end

Ft   = binaryread(file1,idm,jdm,ijdm,1);
%qvectort(abs(qvectort) > 1000) = quantile(qvectort(~isnan(qvectort)),0.5);

F = Ft(Y1:Y2,X1:X2);

F = smooth2(F,2);

FM(itime) = avg_region(F,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0)

end % day loop

%FM(FM == 0) = NaN;
%FM = log(abs(FM));

 set(0,'DefaultFigurePosition',[0 0 1 1]);

figure(owml);
p1 = plot(dayi:dayf,FM)
set(p1,'LineWidth',1.2);
hold on

if(arch == 1)
set(p1,'Color','k')
else
set(p1,'Color','b')
end

if(did == 1)
%set(p1,'Marker','+')
elseif(did == 2)
%set(p1,'Marker','*')
elseif(did == 3)
%set(p1,'Marker','o')
else
%set(p1,'Marker','x')
end

% title('<F>','FontSize',18)
ylabel('<F>','FontSize',18)
xlabel('Time (days)','FontSize',18)
%ylim([-0.5*10e-16 1.5*10e-16])

set(gca,'XTick', 1:6:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)
%set(gca,'XTickLabel',timeBar(1:5:end))

end % depth loop

end % close archive high/low res loop

filename = strcat('./plot/F_',R,'.eps')

print(owml,'-dpsc2',filename);

close all;
end  % region loop
