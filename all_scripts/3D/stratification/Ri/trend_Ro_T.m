clear all;
%%%% dimensions  
gridbfid=fopen('/tamay/mensa/hycom/scripts/topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '/tamay/mensa/hycom/scripts/topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

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
dayf  = 99;
dstep = 1;


owml = figure;
owmla = figure;

for arch = 1:2

for did = 1:2

depth   = readline('/tamay/mensa/hycom/scripts/3D/layersDepth_2',did);
depthid = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_2',did));
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


clear RoM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear');

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
 file2  = strcat('/tamay/mensa/hycom/scripts/3D/kinematics/output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_23.a');
else
 file2  = strcat('/tamay/mensa/hycom/scripts/3D/kinematics/output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_23.a');
end


Vort  = hycomread(file2,idm,jdm,ijdm,depthid);
Rot   = Vort./f;

Rom = abs(Rot(Y1:Y2,X1:X2));

%Rom = avg_region(Rot,tpscx,tpscy,X1,X2,Y1,Y2,0);

RoM(itime) = length(find(Rom > 0.5))/length(find(~isnan(Rom)));

end % day loop

figure(owml);
p1 = plot(dayi:dayf,RoM)
set(p1,'LineWidth',1.2);
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

ylabel('<count(Ro>0.5)>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:6:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

% anomalies

figure(owmla);
p2 = plot(dayi:dayf,RoM-mean(RoM))
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

ylabel('<count(Ro>0.5)>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end),'FontSize',15)

end % depth loop

if (arch == 1)
TRoM = RoM;
end

end % close archive high/low res loop

print(owml,'-dpsc2',strcat('./plot/Ro_',R,'.eps'))
print(owmla,'-dpsc2',strcat('./plot/Ro_a_',R,'.eps'))

%%% differences

owmld = figure;
p3 = plot(dayi:dayf,RoM-TRoM)
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

ylabel('<count(Ro>0.5)>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end),'FontSize',15)

%t = title(strcat(['Ro, high and low res variation, vs time (region ,',R,', depth ',depth,'m,)']));
%set(t,'FontSize',14)
print(owmld,'-dpsc2',strcat('./plot/Ro_diff_',R,'.eps'))


end  % region loop
