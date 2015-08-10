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

tplon = hycomread(file,idm,jdm,ijdm,18);
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

for did = 1:4

depth   = readline('../../../3D/layersDepth_4',did);
depthid = str2num(readline('../../../3D/layersDepthID_4',did));

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;
RiM = 0;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../../../3D/archivesDay');
year  = textread('../../../3D/archivesYear');

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
 file   = strcat('../../../3D/stratification/Ri/output/high-res/ri_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file   = strcat('../../../3D/stratification/Ri/output/low-res/ri_l_016_archv.',lyear,'_',lday,'_00.a');
end


Rit   = binaryread(file,idm,jdm,ijdm,depthid);
%Rit(abs(Rit) > 1000) = quantile(Rit(~isnan(Rit)),0.5);

Rim = Rit(Y1:Y2,X1:X2);
RiM(itime) = length(find(Rim > 0.25 & Rim < 1))/length(find(~isnan(Rim)));

%Rim = avg_region(Rit,tpscx,tpscy,X1,X2,Y1,Y2,0);

%RiM(itime) = Rim;

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
p1 = plot(dayi:dayf,RiM)
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

ylabel('<Ri>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end),'FontSize',15)

% anomalies

figure(owmla);
p2 = plot(dayi:dayf,RiM-mean(RiM))
set(p2,'LineWidth',0.7);
hold on;

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

ylabel('<Ri>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end),'FontSize',15)

end % depth loop

if (arch == 1)
TRiM = RiM;
end

end % close archive high/low res loop

print(owml,'-dpsc2',strcat('./plot/Ri_',R,'.eps'))
print(owmla,'-dpsc2',strcat('./plot/Ri_a_',R,'.eps'))

%%% differences

figure(owmld);
p3 = plot(dayi:dayf,RiM-TRiM)
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

ylabel('<Ri>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end),'FontSize',15)

%t = title(strcat(['Ri and Ro, high and low res variation, vs time (region ,',R,', depth ',depth,'m,)']));
%set(t,'FontSize',14)
print(owmld,'-dpsc2',strcat('./plot/Ri_diff_',R,'.eps'))

%close all;
end  % region loop
