clear; close all;
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


lday = '';

N = '1';

for arch = 1:2

for time  = 199:498

day   = textread('../../archivesDay_all');
year  = textread('../../archivesYear_all');

lday  = digit(day(time),3);
lyear = digit(year(time),4);


if(arch == 1)
file1 = strcat('./output/',N,'/high-res/layer_s_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_R_00.a');
file2 = strcat('./output/',N,'/high-res/layer_s_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_S_00.a');
file3 = strcat('./output/',N,'/high-res/layer_s_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_T_00.a');
else
file1 = strcat('./output/',N,'/low-res/layer_s_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_R_00.a');
file2 = strcat('./output/',N,'/low-res/layer_s_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_S_00.a');
file3 = strcat('./output/',N,'/low-res/layer_s_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_T_00.a');
end

Rt = hycomread(file1,idm,jdm,ijdm,1);
St = hycomread(file2,idm,jdm,ijdm,1);
Tt = hycomread(file3,idm,jdm,ijdm,1);

'plotting...'
file

for region = 1:4

[X1,X2,Y1,Y2,G] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

R = Rt(Y1:Y2,X1:X2);
T = Tt(Y1:Y2,X1:X2);
S = St(Y1:Y2,X1:X2);

ids = X2-X1+1;
jds = Y2-Y1+1;

R = smooth2(R,2);

[gRx,gRy] = gradient(R,lon,lat);
[gTx,gTy] = gradient(T,lon,lat);
[gSx,gSy] = gradient(S,lon,lat);

gradR = sqrt(gRx.^2 + gRy.^2);
gradT = sqrt(gTx.^2 + gTy.^2);
gradS = sqrt(gSx.^2 + gSy.^2);

maxR   = quantile(gradR(~isnan(gradR)),.9);
minR   = quantile(gradR(~isnan(gradR)),.1);
maxT   = quantile(gradT(~isnan(gradT)),.9);
minT   = quantile(gradT(~isnan(gradT)),.1);
maxS   = quantile(gradS(~isnan(gradS)),.9);
minS   = quantile(gradS(~isnan(gradS)),.1);


%%%%%%%%%%%%%%%%%%%%% density

[ch] = figure;
imagesc(lon,lat,gradR);
caxis([minR maxR]);
axis image;
axis xy;
xlabel('Longitude');
ylabel('Latitude');
colorbar

if(arch == 1)
label = strcat('./plot/',N,'/high-res/layerN_gradTSR_h_016_archv.',lyear,'_',lday,'_',N,'_',G,'_R_00.a.eps')
title(['grad Density, layer ',N,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/',N,'/low-res/layerN_gradTSR_l_016_archv.',lyear,'_',lday,'_',N,'_',G,'_R_00.a.eps')
title(['grad Density, layer ',N,', LR, day: ',lday,' year:',lyear]);
end

print(ch,'-dpsc2',label);

close all;

%%%%%%%%%%%%%%%%%%%%% temperature 

[ch] = figure;
imagesc(lon,lat,gradT);
caxis([minT maxT]);
axis image;
axis xy;
xlabel('Longitude');
ylabel('Latitude');
colorbar

if(arch == 1)
label = strcat('./plot/',N,'/high-res/layerN_gradTSR_h_016_archv.',lyear,'_',lday,'_',N,'_',G,'_T_00.a.eps')
title(['grad Temperature, layer ',N,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/',N,'/low-res/layerN_gradTSR_l_016_archv.',lyear,'_',lday,'_',N,'_',G,'_T_00.a.eps')
title(['grad Temperature, layer ',N,', LR, day: ',lday,' year:',lyear]);
end

print(ch,'-dpsc2',label);

close all;

%%%%%%%%%%%%%%%%%%%%% salinity

[ch] = figure;
imagesc(lon,lat,gradS);
caxis([minS maxS]);
axis image;
axis xy;
xlabel('Longitude');
ylabel('Latitude');
colorbar

if(arch == 1)
label = strcat('./plot/',N,'/high-res/layerN_gradTSR_h_016_archv.',lyear,'_',lday,'_',N,'_',G,'_S_00.a.eps')
title(['grad Salinity, layer ',N,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/',N,'/low-res/layerN_gradTSR_l_016_archv.',lyear,'_',lday,'_',N,'_',G,'_S_00.a.eps')
title(['grad Salinity, layer ',N,', LR, day: ',lday,' year:',lyear]);
end

print(ch,'-dpsc2',label);

close all;

end
end
end
