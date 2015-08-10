clear all;
%%%% dimensions  
gridbfid=fopen('../../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

tplon = hycomread(file,idm,jdm,ijdm,12);
tplat = hycomread(file,idm,jdm,ijdm,13);

for region = 1:1

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

for arch = 1:1

for did = 1:2

depth   = readline('../../layersDepth_4',did);
depthid = str2num(readline('../../layersDepthID_4_02',did));

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;


clear gradRhoM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../../archivesDay_all_02');
year  = textread('../../archivesYear_all_02');

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
 file1  = strcat('../../../../GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zr.A');
else
 file1  = strcat('../../../../GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zr.A');
end

Rhot = binaryread(file1,idm,jdm,ijdm,depthid);

Rho = Rhot(Y1:Y2,X1:X2);
Rho = smooth2(Rho,2);

[gRx,gRy] = gradient(Rho,lon,lat);

gradRho = sqrt(gRx.^2 + gRy.^2);

gradRhom = avg_region(gradRho,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);

gradRhoM(itime) = gradRhom/length(find(~isnan(gradRho)));

end % day loop

figure(owml);
p1 = plot(dayi:dayf,gradRhoM)
set(p1,'LineWidth',0.7);
hold on

if(arch == 1)
set(p1,'Color','k')
else
set(p1,'Color','b')
end

if(did == 1)
set(p1,'Marker','+')
elseif(did == 2)
set(p1,'Marker','*')
elseif(did == 3)
set(p1,'Marker','o')
else
set(p1,'Marker','x')
end

ylabel('<\nabla \rho>','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:6:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

end % depth loop

if (arch == 1)
TgradRhoM = gradRhoM;
end

end % close archive high/low res loop
label = strcat('./plot/gradRho_',R,'.eps')
print(owml,'-dpsc2',label)

%close all;
end  % region loop
