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

for region = 1:4

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 50;
dstep = 1;

f1 = figure;
f2 = figure;

minS =  1;
maxS = -1;
minSn =  1;
maxSn = -1;

for arch = 1:2

for did = 1:4

depthid = str2num(readline('../3D/layersDepthID_5_iso',did));

itime = 0;

S = 0;
Sn = 0;

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
else
 file  = strcat('./output/low-res/okuboweiss_l_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('./output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_00.a');
end

tokub = binaryread(file,idm,jdm,ijdm,depthid);
tvort = binaryread(file1,idm,jdm,ijdm,depthid);

okub = tokub(Y1:Y2,X1:X2);
vort = tvort(Y1:Y2,X1:X2).^2;

ids = Y2-Y1+1;
jds = X2-X1+1;

Ot = 0;
Vt = 0;

okub(:,:) = okub(:,:).*pscx(:,:).*pscy(:,:);
vort(:,:) = vort(:,:).*pscx(:,:).*pscy(:,:);

for i = 1:ids
 Ot(i) = trapz(okub(i,~isnan(vort(i,:))));
 Vt(i) = trapz(vort(i,~isnan(vort(i,:))));
end

% Ot = Ot.*lat(:)'./lat(1); % normalize according to grid size... 
% Vt = Vt.*lat(:)'./lat(1); % normalize according to grid size... 

 S(itime)  = trapz(Ot)
 Sn(itime) = trapz(Ot)/trapz(Vt)

end % day loop

%%%%%%%%%% normalize values over area
'normalized'
S = S./sum(pscx(~isnan(vort)).*pscy(~isnan(vort)))
Sn = Sn%./sum(pscx(~isnan(vort)).*pscy(~isnan(vort)))

%% I save M and Q in two temporary arrays to plot later the differences...

figure(f1)

p1 = plot(2:itime+1,S)
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



figure(f2)

p2 = plot(2:itime+1,Sn)
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

end % depth loop
end % close archive high/low res loop


figure(f1);
 set(gca,'XTick', 1:30:itime);
 set(gca,'XTickLabel',timeBar(1:30:end))

 t1 = title(strcat(['A^{-1} \int\int Q dA in time (region ',R,')']));
 set(t1,'FontSize',18)
 print(f1,'-dpsc2',strcat('./plot/OW_S_',R,'.eps'));

figure(f2);
 set(gca,'XTick', 1:30:itime);
 set(gca,'XTickLabel',timeBar(1:30:end))

 t2 = title(strcat(['A^{-1} \int\int Q/\zeta^{2} dA in time (region ',R,')']));
 set(t2,'FontSize',18)
 print(f2,'-dpsc2',strcat('./plot/OW_S_',R,'_norm.eps'));


end  % region loop
