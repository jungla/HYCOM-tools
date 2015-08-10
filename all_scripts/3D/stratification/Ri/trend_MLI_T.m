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
owmla = figure;
owmld = figure;

for arch = 1:2

for did = 1:2

depth   = readline('../../../3D/layersDepth_2',did);
depthid = str2num(readline('../../../3D/layersDepthID_2',did));

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;
MLIM = 0;

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
 file   = strcat('../../../3D/stratification/Ri/output/high-res/ri_h_016_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('../../../3D/kinematics/output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a')
 file4  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zw.A');
else
 file   = strcat('../../../3D/stratification/Ri/output/low-res/ri_l_016_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('../../../3D/kinematics/output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a')
 file4  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zw.A');
end


Rit = binaryread(file,idm,jdm,ijdm,depthid);
Rot = binaryread(file2,idm,jdm,ijdm,1);
Rot = Rot./f;
wt   = binaryread(file4,idm,jdm,ijdm,depthid);

w   = wt(Y1:Y2,X1:X2);
Rim = Rit(Y1:Y2,X1:X2);
Rom = Rot(Y1:Y2,X1:X2);

w = w./std(w(~isnan(w)));

mli = 0;
s   = 0;


for i = 1:Y2-Y1+1
 for j = 1:X2-X1+1
  if(Rim(i,j) < 1 && 0.5 < Rim(i,j)*Rom(i,j)^2 && Rim(i,j)*Rom(i,j)^2 <  1.5) % &&  abs(w(i,j)) > 1)
%  if(Rim(i,j) < 1 && abs(w(i,j)) > 2)
   mli = mli + 1
  end
 end
end
%Rom = avg_region(Rot,tpscx,tpscy,X1,X2,Y1,Y2,0);

%MLIM(itime) = mli;
MLIM(itime) = mli/length(find(~isnan(Rim)));

%MLIm = avg_region(MLIt,tpscx,tpscy,X1,X2,Y1,Y2,0);

%MLIM(itime) = MLIm;

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
p1 = plot(dayi:dayf,MLIM)
set(p1,'LineWidth',1.2);
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

ylabel('<count(MLI)>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:3:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

% anomalies

figure(owmla);
p2 = plot(dayi:dayf,MLIM-mean(MLIM))
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

ylabel('<MLI>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end),'FontSize',15)

end % depth loop

if (arch == 1)
TMLIM = MLIM;
end

end % close archive high/low res loop

print(owml,'-dpsc2',strcat('./plot/MLI_',R,'.eps'))
print(owmla,'-dpsc2',strcat('./plot/MLI_a_',R,'.eps'))

%%% differences

figure(owmld);
p3 = plot(dayi:dayf,MLIM-TMLIM)
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

ylabel('<MLI>','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end),'FontSize',15)

%t = title(strcat(['MLI and Ro, high and low res variation, vs time (region ,',R,', depth ',depth,'m,)']));
%set(t,'FontSize',14)
print(owmld,'-dpsc2',strcat('./plot/MLI_diff_',R,'.eps'))

%close all;
end  % region loop
