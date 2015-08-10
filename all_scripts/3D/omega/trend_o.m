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


owml = figure;

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

figure(owml);

p1 = plot(dayi:dayf,OaM)
set(p1,'LineWidth',1.2);
hold on

if(arch == 1)
set(p1,'Color','k')
else
set(p1,'Color','b')
end

%if(did == 1)
%set(p1,'Marker','+')
%elseif(did == 2)
%set(p1,'Marker','*')
%elseif(did == 3)
%set(p1,'Marker','o')
%else
%set(p1,'Marker','x')
%end

ylabel('<\omega>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:3:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

end % depth loop
end % close archive high/low res loop

label = strcat('./plot/Oa_',R,'.eps')
print(owml,'-dpsc2',label)
close all;


%close all;
end  % region loop
