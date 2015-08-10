clear all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

tplon = hycomread(file,idm,jdm,ijdm,18);
tplat = hycomread(file,idm,jdm,ijdm,13);

for region = 6:6

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 49;
dstep = 1;

depth   = importdata('../layersDepth_ML');
kl = size(depth,1);

owml = figure;

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


clear wM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../archivesDay_bkup');
year  = textread('../archivesYear_bkup');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;

% x bar for plotting
timeBar(itime) = day(time);

arch
lday
lyear

if (arch == 1)
 file1  = strcat('./output/high-res/O_a_h_',lyear,'_',lday,'_00.a');
else
 file1  = strcat('./output/low-res/O_a_l_',lyear,'_',lday,'_00.a');
end

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;

if (arch == 1)
 filem = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
else
 filem = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
end

fmt = hycomread(filem,idm,jdm,ijdm,6);
fm = fmt(Y1:Y2,X1:X2)./9806;

for did=1:kl
 Oat(:,:,did) = abs(binaryread(file1,ids,jds,ijds,did));
end

OaM(itime) = avg_3D(Oat,pscx,pscy,fm,depth);

end % day loop

p1 = plot(dayi:dayf,OaM)
set(p1,'LineWidth',1.2);
hold on

if(arch == 1)
set(p1,'Color','k')
else
set(p1,'Color','b')
end


ylabel('<\omega>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:3:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

end % close archive high/low res loop
label = strcat('./plot/Oa_',R,'.eps')
print(owml,'-dpsc2',label)
close all;


%close all;
end  % region loop
