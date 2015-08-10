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

omega  = 7.2921150*10^-5;
f(:,:) = zeros(jdm,idm);
f(:,:) = 2*omega*sin(tlat(:,:)*pi/90);

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 49;
dstep = 1;


owmlz  = figure;
owmlaz = figure;
owmlk  = figure;
owmlak = figure;

for arch = 1:2

for did =1:1

depth   = readline('../layersDepth_4',did);
depthid = str2num(readline('../layersDepthID_4',did));
depth

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;

clear ZM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../archivesDay');
year  = textread('../archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;

% x bar for plotting
timeBar(itime) = day(time);

lday
lyear
depth

if (arch == 1)
 file  = strcat('./output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
else
 file  = strcat('./output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
end

   tvort = hycomread(file,idm,jdm,ijdm,1);

   vort = tvort(Y1:Y2,X1:X2);
   vort = vort./(8*10^-5);
   maxv = max(vort(~isnan(vort)));
   minv = min(vort(~isnan(vort)));
   [nh,xout] = hist(vort(~isnan(vort)), [minv:(maxv-minv)/100:maxv]);

   ZM(itime) = skewness(nh,0);
   KM(itime) = kurtosis(nh);

end % day loop
 ZM
 KM

%%%%%%%%% plot skeness  %%%%%

figure(owmlz);
p1 = plot(dayi:dayf,ZM)
set(p1,'LineWidth',0.7);
hold on;

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

ylabel('Skewness \zeta^z','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))

%%%%%%%%% plot kurtosis  %%%%%

figure(owmlk);
p1 = plot(dayi:dayf,KM)
set(p1,'LineWidth',0.7);
hold on;

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

ylabel('Kurtosis \zeta^z','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))


% anomalies kurtosis

figure(owmlak);
p2 = plot(dayi:dayf,KM-mean(KM))
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

ylabel('kurtosis(\zeta^z)','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))

% anomalies skewness

figure(owmlaz);
p2 = plot(dayi:dayf,ZM-mean(ZM))
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

ylabel('skewness(\zeta^z)','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))

print(owmlk,'-dpsc2',strcat('./plot/trend_kurtosisZ_',R,'.eps'))
print(owmlak,'-dpsc2',strcat('./plot/trend_kurtosisZ_a_',R,'.eps'))
print(owmlz,'-dpsc2',strcat('./plot/trend_skewnessZ_',R,'.eps'))
print(owmlaz,'-dpsc2',strcat('./plot/trend_skewnessZ_a_',R,'.eps'))

end % depth loop


end % close archive high/low res loop

end  % region loop
