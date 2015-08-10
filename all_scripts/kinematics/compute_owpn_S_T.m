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

X1 = 1;
X2 = idm;
Y1 = 1;
Y2 = jdm;
R = 'T';

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 50;
dstep = 1;

owml = figure;

minS =  1;
maxS = -1;

for arch = 1:2

for did = 1:4

depthid = str2num(readline('../../3D/layersDepthID_3',did));

depthid

itime = 0;

S = 0;

for time  = dayi:dstep:dayf-dstep

day   = textread('../archivesDay');
year  = textread('../archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;
timeBar(itime) = day(time);

lday    
lyear
depth

if (arch == 1)
 file  = strcat('~/hycom/scripts/3D/kinematics/output/high-res/okuboweiss_h_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('~/hycom/scripts/3D/kinematics/output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file  = strcat('~/hycom/scripts/3D/kinematics/output/low-res/okuboweiss_l_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('~/hycom/scripts/3D/kinematics/output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_00.a');
end

tokub = hycomread(file,idm,jdm,ijdm,depthid);
tvort = hycomread(file1,idm,jdm,ijdm,depthid);

%tokub = tokub/(8*10^-5);

%plon = tplon(Y1:Y2,X1:X2);
%plat = tplat(Y1:Y2,X1:X2);
okub = tokub(Y1:Y2,X1:X2);
vort = tvort(Y1:Y2,X1:X2).^2;


ids = Y2-Y1+1;


Ot = 0;
Vt = 0;

for i = 1:ids
 Ot(i) = trapz(okub(i,~isnan(okub(i,:))));
 Vt(i) = trapz(vort(i,~isnan(vort(i,:))));
end

 Ot = Ot.*lat(:)'./lat(1); % normalize according to grid size... it has con consider also the number of NaNs
 Vt = Vt.*lat(:)'./lat(1); % normalize according to grid size... it has con consider also the number of NaNs

 S(time) = trapz(Ot)/trapz(Vt);

end % day loop

%%%%%%%%%% normalize values over area

S = S./sum(sum(pscx.*pscy));

minS = min(S,minS);
maxS = max(S,maxS);

%% I save M and Q in two temporary arrays to plot later the differences...


p1 = plot(2:itime+1,S)
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

end % depth loop
end % close archive high/low res loop

set(gca,'XTick', 1:5:itime);
set(gca,'XTickLabel',timeBar(1:5:end))

if (arch == 1)
 t = title(strcat(['\zeta^{-2}2 A^{-1} \int\int Q dA in time (region ',R,')']));
 set(t,'FontSize',18)
 print(owml,'-dpsc2',strcat('./plot/OW_S_',R,'.eps'));
else
 t = title(strcat(['\zeta^{-2}A^{-1} \int\int Q dA in time (region ',R,')']));
 set(t,'FontSize',18)
 print(owml,'-dpsc2',strcat('./plot/OW_S_',R,'.eps'));
end

