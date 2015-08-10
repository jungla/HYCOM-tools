clear; close all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../../topo0.02/regional.grid.a';

lon = hycomread(file,idm,jdm,ijdm,1);
lat = hycomread(file,idm,jdm,ijdm,2);

lon = lon(1,:);
lat = lat(:,1);


for arch = 1:2

for time  = 1:2

day   = textread('../../3D/archivesDay_2');
year  = textread('../../3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did = 1:1

depth = readline('../../3D/layersDepth_4a',did);
depthid = str2num(readline('../../3D/layersDepthID_4a',did));
depth

label = 'okuboweiss'

if (arch == 1)
 file = strcat('./output/high-res/',label,'_a_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file = strcat('./output/low-res/',label,'_a_l_016_archv.',lyear,'_',lday,'_00.a');
end

okub = binaryread(file,idm,jdm,ijdm,depthid);
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

 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)


 %caxis([-1*10^-5 7*10^-4])
% caxis([-5*10^-5 5*10^-5])
 caxis([-0.2 +0.2])

% title([label,', day ',lday,', year ',lyear]);

 if(arch == 1)
  label = strcat('./plot/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_',depth,'_00','.eps')
 else
  label = strcat('./plot/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_',depth,'_00','.eps')
 end

 print(ch,'-dpsc2',label);

close all;

end
end
end
