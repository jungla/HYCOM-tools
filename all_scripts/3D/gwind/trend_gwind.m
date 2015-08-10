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
dayf  = 49;
dstep = 1;

ogwindml = figure;
ogwindmla = figure;
ogwindmld = figure;

for arch = 1:2

for did = 1:1

depth   = readline('../../3D/layersDepth_4',did);
depthid = str2num(readline('../../3D/layersDepthID_4',did));

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;


clear gwindM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../../3D/archivesDay');
year  = textread('../../3D/archivesYear');

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
 file2  = strcat('./output/high-res/gwind_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file2  = strcat('./output/low-res/gwind_l_016_archv.',lyear,'_',lday,'_00.a');
end

gwindt = binaryread(file2,idm,jdm,ijdm,depthid);
gwind  = gwindt(Y1:Y2,X1:X2);

gwindm = avg_region(gwindt,tpscx,tpscy,X1,X2,Y1,Y2,0);

gwindM(itime) = gwindm/length(gwind(~isnan(gwind)));

end % day loop


%%%%%% SD normalization

%sdM  = nanstd(M);
%sdQ  = nanstd(Q);

%M = M./sdM;
%Q = Q./sdM;

%%%%%%% gwindithout SD normalization

%miny = 0;
%maxy = 3.5*10^-3;

%minya = -8*10^-4;
%maxya =  8*10^-4;

%%%%%%% gwindith SD normalization

%miny = 0;
%maxy = 3.5*10^-3;

%minya = -8*10^-4;
%maxya =  8*10^-4;

figure(ogwindml);
p1 = plot(dayi:dayf,gwindM)
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

ylabel('<\epsilon>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:3:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

% anomalies

figure(ogwindmla);
p2 = plot(dayi:dayf,gwindM-mean(gwindM))
set(p2,'LineWidth',0.7);
hold on;

if(arch == 1)
set(p2,'Color','k')
else
set(p2,'Color','b')
end

if(did == 1)
%set(p2,'Marker','+')
elseif(did == 2)
%set(p2,'Marker','*')
elseif(did == 3)
%set(p2,'Marker','o')
else
%set(p2,'Marker','x')
end

ylabel('<\epsilon>','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))

end % depth loop

if (arch == 1)
TgwindM = gwindM;
end

end % close archive high/logwind res loop

print(ogwindml,'-dpsc2',strcat('./plot/gwind_',R,'.eps'))
print(ogwindmla,'-dpsc2',strcat('./plot/gwind_a_',R,'.eps'))

%%% differences

figure(ogwindmld);
p3 = plot(dayi:dayf,gwindM-TgwindM)
set(p3,'LineWidth',0.7);
hold on;

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

ylabel('<abs(gwind)>','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))

%t = title(strcat(['gwind and Ro, high and logwind res variation, vs time (region ,',R,', depth ',depth,'m,)']));
%set(t,'FontSize',14)
print(ogwindmld,'-dpsc2',strcat('./plot/gwind_diff_',R,'.eps'))

%close all;
end  % region loop
