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

tplon = hycomread(file,idm,jdm,ijdm,12);
tplat = hycomread(file,idm,jdm,ijdm,13);

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 50;
dstep = 1;


minS =  1;
maxS = -1;
minSn =  1;
maxSn = -1;

for arch = 1:2

f0 = figure;

%clear OM SM VM DM

for did = 1:1

depthid = str2num(readline('../../3D/layersDepthID_2',did));

itime = 0;


for time  = 1:1:98

day   = textread('../archivesDay');
year  = textread('../archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;
timeBar(itime) = day(time);

lday    
lyear
depthid

if (arch == 1)
 file   = strcat('./output/high-res/okuboweiss_h_016_archv.',lyear,'_',lday,'_23.a');
 file1  = strcat('./output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_23.a');
 file2  = strcat('./output/high-res/divergence_h_016_archv.',lyear,'_',lday,'_23.a');
 file3  = strcat('./output/high-res/shearing_h_016_archv.',lyear,'_',lday,'_23.a');
 file4  = strcat('./output/high-res/stretching_h_016_archv.',lyear,'_',lday,'_23.a');
else
 file   = strcat('./output/low-res/okuboweiss_l_016_archv.',lyear,'_',lday,'_23.a');
 file1  = strcat('./output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_23.a');
 file2  = strcat('./output/low-res/divergence_l_016_archv.',lyear,'_',lday,'_23.a');
 file3  = strcat('./output/low-res/shearing_l_016_archv.',lyear,'_',lday,'_23.a');
 file4  = strcat('./output/low-res/stretching_l_016_archv.',lyear,'_',lday,'_23.a');
end

tokub  = binaryread(file ,idm,jdm,ijdm,did);
tvort  = binaryread(file1,idm,jdm,ijdm,did);
tdiv   = binaryread(file2,idm,jdm,ijdm,did);
tshear = binaryread(file3,idm,jdm,ijdm,did);
tstret = binaryread(file4,idm,jdm,ijdm,did);

O = tokub(Y1:Y2,X1:X2);
V = tvort(Y1:Y2,X1:X2).^2;
D  = tdiv(Y1:Y2,X1:X2).^2;
S = tshear(Y1:Y2,X1:X2).^2 + tstret(Y1:Y2,X1:X2).^2;

ids = Y2-Y1+1;
jds = X2-X1+1;

Om = avg_region(O,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
OM(itime) = Om;%/length(find(~isnan(O)));

Vm = avg_region(V,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
VM(itime) = Vm;%/length(find(~isnan(V)));

Dm = avg_region(D,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
DM(itime) = Dm;%/length(find(~isnan(D)));

Sm = avg_region(S,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
SM(itime) = Sm;%/length(find(~isnan(S)));

end % day loop


%% I save M and Q in two temporary arrays to plot later the differences...

p0 = plot(2:itime+1,OM)
hold on
p1 = plot(2:itime+1,SM)
p2 = plot(2:itime+1,VM)
p3 = plot(2:itime+1,DM)

set(p0,'LineWidth',1.2);
set(p1,'LineWidth',1.2);
set(p2,'LineWidth',1.2);
set(p3,'LineWidth',1.2);

set(p0,'Color','r')
set(p1,'Color','k')
set(p2,'Color',[0.5 0.5 0.5])
set(p3,'Color','b')

set(gca,'XTick', 1:6:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)
xlabel('Time (days)','FontSize',18);

xlim([1 itime])
ylim([-2*10^-10 20*10^-10])


end % depth loop

if arch == 1
 label = strcat('./plot/dssv_h_',R,'.eps');
else
 label = strcat('./plot/dssv_l_',R,'.eps');
end

 print(f0,'-dpsc2',label);

end % close archive high/low res loop



close all;


end  % region loop
