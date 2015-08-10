clear all;
%%%% dimensions  
gridbfid=fopen('../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../topo0.02/regional.grid.a';

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
dayf  = 498;
dstep = 1;

owml = figure;
owmla = figure;
owmld = figure;

for arch = 1:2

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;
RdM = 0;

for time  = dayi:dayf

day   = textread('../3D/archivesDay_all');
year  = textread('../3D/archivesYear_all');

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
 file   = strcat('./output/high-res/rd_h_016_archv.',lyear,'_',lday,'_00.a')
else
 file   = strcat('./output/low-res/rd_l_016_archv.',lyear,'_',lday,'_00.a')
end


Rdt   = binaryread(file,idm,jdm,ijdm,1);
%Rdt(abs(Rdt) > 1000) = quantile(Rdt(~isnan(Rdt)),0.5);

% Rd is actually Rd^2 and can be positive or negative...

Rdm = Rdt(Y1:Y2,X1:X2);
Rdm = abs(Rdm(~isnan(Rdm)));
Rdm = sqrt(Rdm)/1000;
RdM(itime) = sum(abs(Rdm))/length(Rdm);

%Rdm = avg_region(Rdt,tpscx,tpscy,X1,X2,Y1,Y2,0);

%RdM(itime) = Rdm;

end % day loop


%%%%%% SD normalization

%sdM  = nanstd(M);
%sdQ  = nanstd(Q);

%M = M./sdM;
%Q = Q./sdM;

%%%%%%% without SD normalization

%miny = 0;
%maxy = 3.5*10^-3;

%minya = -8*10^-4;
%maxya =  8*10^-4;

%%%%%%% with SD normalization

%miny = 0;
%maxy = 3.5*10^-3;

%minya = -8*10^-4;
%maxya =  8*10^-4;

figure(owml);
p1 = plot(dayi:dayf,RdM)
set(p1,'LineWidth',1.2);
hold on

if(arch == 1)
 set(p1,'Color','k')
else
 set(p1,'Color','b')
end

ylabel('<Rd>','FontSize',18)
xlabel('Time (days)','FontSize',18)
ylim([0 20])

set(gca,'XTick', 1:30:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

end % close archive high/low res loop

label = strcat('./plot/Rd_',R,'.eps')

print(owml,'-dpsc2',label)


close all;
end  % region loop
