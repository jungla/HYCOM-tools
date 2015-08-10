clear; close all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line1 =fgetl(gridbfid);
idm=sscanf(line1,'%f',1);
line1 =fgetl(gridbfid);
jdm=sscanf(line1,'%f',1);
ijdm=idm*jdm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../../topo0.02/regional.grid.a';


tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

for arch = 1:2

for time  = 1:2

if arch == 1
 day   = textread('../../3D/archivesDay_2_h_lcs');
 year  = textread('../../3D/archivesYear_2_h_lcs');
else
 day   = textread('../../3D/archivesDay_2_l_lcs');
 year  = textread('../../3D/archivesYear_2_l_lcs');
end

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear
    
for region = 3:3 %1:2:5

region+time
    
[X1,X2,Y1,Y2,R,lcs] = regions_lcs(region+time,arch);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);
 
for did = 3:3
 
depth = readline('../layersDepth_4',did);

label = 'okuboweiss'

if (arch == 1)
 file = strcat('./output/high-res/',label,'_a_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file = strcat('./output/low-res/',label,'_a_l_016_archv.',lyear,'_',lday,'_00.a');
end

tokub = hycomread(file,idm,jdm,ijdm,did);
okub = tokub(Y1:Y2,X1:X2);
okub = okub/(8*10^-5)^2;

'plotting...';

 ch = figure();

% imagesc(lon,lat,okub);
 [p1,p1] = contourf(lon,lat,okub,50);
 set(p1,'LineStyle','none');
 axis xy;
 axis image;

 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)

 xlabel('Longitude','Fontsize',21);
 ylabel('Latitude','Fontsize',21);
 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)


 %caxis([-1*10^-5 7*10^-4])
% caxis([-5*10^-5 5*10^-5])
% caxis([-0.2 +0.2])


if arch == 1
  title(['OW, HR (',depth,'m)'],'Fontsize',21);
  label = strcat('./plot/',label,'_h_',lyear,'_',lday,'_',depth,'_',R,'_00_lcs','.eps')
else
  title(['OW, LR (',depth,'m)'],'Fontsize',21);
  label = strcat('./plot/',label,'_l_',lyear,'_',lday,'_',depth,'_',R,'_00_lcs','.eps')
end


 print(ch,'-dpsc2',label);

close all;

end
end
end
end
