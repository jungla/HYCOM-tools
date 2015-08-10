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
dayf  = 50;
dstep = 1;

f0 = figure;
f1 = figure;
f2 = figure;
f3 = figure;
f4 = figure;

minS =  1;
maxS = -1;
minSn =  1;
maxSn = -1;

for arch = 1:2

for did = 1:4

depthid = str2num(readline('../3D/layersDepthID_5_iso',did));

itime = 0;

clear OM SM VM DM

for time  = 1:5:498

day   = textread('../archivesDay_all');
year  = textread('../archivesYear_all');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;
timeBar(itime) = day(time);

lday    
lyear
depthid

if (arch == 1)
 file  = strcat('./output/high-res/okuboweiss_h_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('./output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_00.a');
 file2  = strcat('./output/high-res/divergence_h_016_archv.',lyear,'_',lday,'_00.a');
 file3  = strcat('./output/high-res/shearing_h_016_archv.',lyear,'_',lday,'_00.a');
 file4  = strcat('./output/high-res/stretching_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file  = strcat('./output/low-res/okuboweiss_l_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('./output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_00.a');
 file2  = strcat('./output/low-res/divergence_l_016_archv.',lyear,'_',lday,'_00.a');
 file3  = strcat('./output/low-res/shearing_l_016_archv.',lyear,'_',lday,'_00.a');
 file4  = strcat('./output/low-res/stretching_l_016_archv.',lyear,'_',lday,'_00.a');
end

tokub  = binaryread(file ,idm,jdm,ijdm,depthid);
tvort  = binaryread(file1,idm,jdm,ijdm,depthid);
tdiv   = binaryread(file2,idm,jdm,ijdm,depthid);
tshear = binaryread(file3,idm,jdm,ijdm,depthid);
tstret = binaryread(file4,idm,jdm,ijdm,depthid);

O = tokub(Y1:Y2,X1:X2);
V = tvort(Y1:Y2,X1:X2).^2;
D  = tdiv(Y1:Y2,X1:X2).^2;
shear = tshear(Y1:Y2,X1:X2);
stret = tstret(Y1:Y2,X1:X2);
S = shear.^2 + stret.^2;

ids = Y2-Y1+1;
jds = X2-X1+1;


Om = avg_region(O,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
OM(itime) = Om;%/length(find(~isnan(O)));

Sm = avg_region(S,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
SM(itime) = Sm;%/length(find(~isnan(S)));

Vm = avg_region(V,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
VM(itime) = Vm;%/length(find(~isnan(V)));

Dm = avg_region(D,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
DM(itime) = Dm;%/length(find(~isnan(D)));

end % day loop


%% I save M and Q in two temporary arrays to plot later the differences...

figure(f0)

p0 = plot(2:itime+1,OM)
hold on

set(p0,'LineWidth',0.7);

if(arch == 1)
set(p0,'Color','k')
else
set(p0,'Color','b')
end

if(did == 1)
set(p0,'Marker','+')
elseif(did == 2)
set(p0,'Marker','*')
elseif(did == 3)
set(p0,'Marker','o')
else
set(p0,'Marker','x')
end

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))


figure(f1)

p1 = plot(2:itime+1,SM)
hold on

set(p1,'LineWidth',0.7);

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

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))


figure(f2)

p2 = plot(2:itime+1,VM)
hold on

set(p2,'LineWidth',0.7);

if(arch == 1)
set(p2,'Color','k')
else
set(p2,'Color','b')
end

if(did == 1)
set(p2,'Marker','+')
elseif(did == 2)
set(p2,'Marker','*')
elseif(did == 3)
set(p2,'Marker','o')
else
set(p2,'Marker','x')
end

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))

figure(f3)

p3 = plot(2:itime+1,DM)
hold on

set(p3,'LineWidth',0.7);

if(arch == 1)
set(p3,'Color','k')
else
set(p3,'Color','b')
end

if(did == 1)
set(p3,'Marker','+')
elseif(did == 2)
set(p3,'Marker','*')
elseif(did == 3)
set(p3,'Marker','o')
else
set(p3,'Marker','x')
end

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))

end % depth loop
end % close archive high/low res loop


figure(f1);
 set(gca,'XTick', 1:30:itime);
 set(gca,'XTickLabel',timeBar(1:30:end))

 t1 = title(strcat(['A^{-1} \int\int S^2 dA in time (region ',R,')']));
 set(t1,'FontSize',18)
 print(f1,'-dpsc2',strcat('./plot/Str_S_',R,'.eps'));


figure(f2);
 set(gca,'XTick', 1:30:itime);
 set(gca,'XTickLabel',timeBar(1:30:end))

 t2 = title(strcat(['A^{-1} \int\int Z^2 dA in time (region ',R,')']));
 set(t2,'FontSize',18)
 print(f2,'-dpsc2',strcat('./plot/Ens_S_',R,'.eps'));


figure(f3);
 set(gca,'XTick', 1:30:itime);
 set(gca,'XTickLabel',timeBar(1:30:end))

 t3 = title(strcat(['A^{-1} \int\int Div^2 dA in time (region ',R,')']));
 set(t3,'FontSize',18)
 print(f3,'-dpsc2',strcat('./plot/Div_S_',R,'.eps'));



end  % region loop
