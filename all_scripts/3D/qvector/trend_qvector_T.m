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

for region = 1:4

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 49;
dstep = 1;

owml = figure;
owmla = figure;
owmld = figure;

for arch = 1:2

for did = 1:1

depth   = readline('../layersDepth_4',did);
depthid = str2num(readline('../layersDepthID_4',did));

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

for time  = dayi:dstep:dayf-dstep+1

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
 file1  = strcat('./output/high-res/qvectorx_h_02_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('./output/high-res/qvectory_h_02_archv.',lyear,'_',lday,'_00.a')
else
 file1  = strcat('./output/low-res/qvectorx_l_02_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('./output/low-res/qvectory_l_02_archv.',lyear,'_',lday,'_00.a')
end

qxt   = binaryread(file1,idm,jdm,ijdm,depthid);
qyt   = binaryread(file2,idm,jdm,ijdm,depthid);
%qvectort(abs(qvectort) > 1000) = quantile(qvectort(~isnan(qvectort)),0.5);

qx = qxt(Y1:Y2,X1:X2);
qy = qyt(Y1:Y2,X1:X2);

qc = abs(divergence(qx,qy)); %sqrt(qx.^2 + qy.^2);

qcM(itime) = mean(qc(~isnan(qc)));



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
p1 = plot(dayi:dayf,qcM)
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

ylabel('<\nabla \cdot Q>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:3:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

end % depth loop

end % close archive high/low res loop

print(owml,'-dpsc2',strcat('./plot/qvector_',R,'.eps'))

close all;
end  % region loop
