clear; close all;
%%%% dimensions  
gridbfid=fopen('../../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);

ijdm=idm*jdm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% field indices in the archv file minus 1 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);


lday = '';

depth = '1';

for arch = 1:1

for time  = 1:2

day   = textread('../../archivesDay_2');
year  = textread('../../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:1

depth = readline('../../layersDepth_7',did);
depthid = str2num(readline('../../layersDepthID_7',did));
depth

depth

if(arch == 1)
file1  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_23_3zr.a');
file2  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_23_3zs.a');
file3  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_23_3zt.a');
else
file1  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_23_3zr.a');
file2  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_23_3zs.a');
file3  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_23_3zt.a');
end

Rt = binaryread(file1,idm,jdm,ijdm,depthid);
St = binaryread(file2,idm,jdm,ijdm,depthid);
Tt = binaryread(file3,idm,jdm,ijdm,depthid);

'plotting...'
file

for region = 5:5

[X1,X2,Y1,Y2,G] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

R = Rt(Y1:Y2,X1:X2);
T = Tt(Y1:Y2,X1:X2);
S = St(Y1:Y2,X1:X2);


if time == 1
 minT = 25; 
 maxT = 29;
 minS = 36.1;
 maxS = 36.6;
 minR = 31.6;
 maxR = 32.3;
else
 minT = 19;
 maxT = 23;
 minS = 36.3;
 maxS = 36.7;
 minR = 33.8;
 maxR = 34.5;
end

 if did > 2
  minT = quantile(T(~isnan(T)),0.1);
  maxT = quantile(T(~isnan(T)),0.9);
  minS = quantile(S(~isnan(S)),0.1);
  maxS = quantile(S(~isnan(S)),0.9);
  minR = quantile(R(~isnan(R)),0.1);
  maxR = quantile(R(~isnan(R)),0.9);
 end

%%%%%%%%%%%%%%%%%%%%% density

[ch] = figure;

R = smooth2(R,2);

imagesc(lon,lat,R);
caxis([minR maxR])
axis image;
axis xy;
xlabel('Longitude','Fontsize',15);
ylabel('Latitude','Fontsize',15);
set(gca,'FontSize',14)
cb = colorbar;
set(cb, 'FontSize',12)

if(arch == 1)
label = strcat('./plot/high-res/layer_z_TSR_h_016_archv.',lyear,'_',lday,'_',depth,'_',G,'_R_00.a.eps')
title(['Density, layer ',depth,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/low-res/layer_z_TSR_l_016_archv.',lyear,'_',lday,'_',depth,'_',G,'_R_00.a.eps')
title(['Density, layer ',depth,', LR, day: ',lday,' year:',lyear]);
end

print(ch,'-dpsc2',label);

close all;

%%%%%%%%%%%%%%%%%%%%% temperature 

[ch] = figure;
imagesc(lon,lat,T);
caxis([minT maxT])
axis image;
axis xy;
xlabel('Longitude','Fontsize',15);
ylabel('Latitude','Fontsize',15);
set(gca,'FontSize',14)
cb = colorbar;
set(cb, 'FontSize',12)

if(arch == 1)
label = strcat('./plot/high-res/layer_z_TSR_h_016_archv.',lyear,'_',lday,'_',depth,'_',G,'_T_00.a.eps')
title(['Temperature, layer ',depth,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/low-res/layer_z_TSR_l_016_archv.',lyear,'_',lday,'_',depth,'_',G,'_T_00.a.eps')
title(['Temperature, layer ',depth,', LR, day: ',lday,' year:',lyear]);
end

print(ch,'-dpsc2',label);

close all;

%%%%%%%%%%%%%%%%%%%%% salinity

[ch] = figure;
imagesc(lon,lat,S);
caxis([minS maxS])
axis image;
axis xy;
xlabel('Longitude','Fontsize',15);
ylabel('Latitude','Fontsize',15);
set(gca,'FontSize',14)
cb = colorbar;
set(cb, 'FontSize',12)

if(arch == 1)
label = strcat('./plot/high-res/layer_z_TSR_h_016_archv.',lyear,'_',lday,'_',depth,'_',G,'_S_00.a.eps')
title(['Salinity, layer ',depth,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/low-res/layer_z_TSR_l_016_archv.',lyear,'_',lday,'_',depth,'_',G,'_S_00.a.eps')
title(['Salinity, layer ',depth,', LR, day: ',lday,' year:',lyear]);
end

print(ch,'-dpsc2',label);

close all;

end
end
end
end
