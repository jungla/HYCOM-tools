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



miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;


clear gradSSTM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../../archivesDay');
year  = textread('../../archivesYear');

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
 file0  = strcat('../../../../GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_23_3zt.a');
else
 file0  = strcat('../../../../GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_23_3zt.a');
end

SSTt = binaryread(file1,idm,jdm,ijdm,1);
SST = SSTt(Y1:Y2,X1:X2);
SST = smooth2(SST,2);
[gRx,gRy] = gradient(SST,lon,lat);
gradSST = sqrt(gRx.^2 + gRy.^2);
gradSSTm = avg_region(gradSST,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
gradSSTM(itime) = gradSSTm/length(find(~isnan(gradSST)));

for did = 1:5
did

SSTth = hycomread(file0,idm,jdm,ijdm,did*5+10);
SSTh = SSTth(Y1:Y2,X1:X2);
SSTh = smooth2(SSTh,2);
[gRxh,gRyh] = gradient(SSTh,lon,lat);
gradSSTh = sqrt(gRxh.^2 + gRyh.^2);
gradSSTmh = avg_region(gradSSTh,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);
gradSSTMh(itime,did) = gradSSTmh/length(find(~isnan(gradSSTh)));

end % depth

end % day loop

figure(owml);
hold on
p1 = plot(dayi:dayf,log(gradSSTM))
for did = 1:size(gradSSTMh,2)
plot(dayi:dayf,log(gradSSTMh(dayi:dayf,did)),'Color',[(size(gradSSTMh,2)-did)/size(gradSSTMh,2) (size(gradSSTMh,2)-did)/size(gradSSTMh,2) (size(gradSSTMh,2)-did)/size(gradSSTMh,2)],'LineWidth',1.2)
%plot(dayi:dayf,log(gradSSTMh(dayi:dayf,did)),'Color','k','LineWidth',1.2)
end

set(p1,'LineWidth',1.2);
set(p1,'Color','b')

ylabel('<\nabla SST>','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:6:itime);

set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)


end % close archive high/low res loop

label = strcat('./plot/gradSST_',R,'_ZvsH.eps')
print(owml,'-dpsc2',label)

%close all;
end  % region loop
