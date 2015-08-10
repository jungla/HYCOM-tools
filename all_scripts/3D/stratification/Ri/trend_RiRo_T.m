clear all;
%%%% dimensions  
gridbfid=fopen('../../../topo0.02/regional.grid.b','r');
line1=fgetl(gridbfid);
idm=sscanf(line1,'%f',1);
line1=fgetl(gridbfid);
jdm=sscanf(line1,'%f',1);
ijdm=idm*jdm;

file = '../../../topo0.02/regional.grid.a';

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

owml = figure;

for did =1:1

depth   = readline('../../../3D/layersDepth_4',did);
depthid = str2num(readline('../../../3D/layersDepthID_4',did));

%miny =  100;
%maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;

for arch = 1:2

clear RoM RiM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../../../3D/archivesDay');
year  = textread('../../../3D/archivesYear');

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
 file   = strcat('../../../3D/stratification/Ri/output/high-res/ri_h_016_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('../../../3D/kinematics/output/high-res/vorticity_a_h_016_archv.',lyear,'_',lday,'_00.a')
else
 file   = strcat('../../../3D/stratification/Ri/output/low-res/ri_l_016_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('../../../3D/kinematics/output/low-res/vorticity_a_l_016_archv.',lyear,'_',lday,'_00.a')
end


Rit   = binaryread(file,idm,jdm,ijdm,depthid);
Vort  = binaryread(file2,idm,jdm,ijdm,depthid);
Rot   = Vort./f;
% to make Ri reasonable... erase too big values!!
Rit(Rit > 200) = quantile(Rit(~isnan(Rit)),0.5);

But = Rit.*(Rot.^2);

Bum = avg_region(But,tpscx,tpscy,X1,X2,Y1,Y2,0);

BuM(time) = Bum;

end % day loop

figure(owml);
p1 = plot(dayi:dayf,BuM)
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

ylabel('Bu^2','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end),'FontSize',15)

end % close archive high/low res loop

print(owml,'-dpsc2',strcat('./plot/RiRo2_',R,'.eps'))

end % depth loop
end  % region loop
