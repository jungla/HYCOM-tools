clear; close all;
%%%% dimensions  
gridbfid=fopen('../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../topo0.02/regional.grid.a';

lon = hycomread(file,idm,jdm,ijdm,1);
lat = hycomread(file,idm,jdm,ijdm,2);

lon = lon(1,:);
lat = lat(:,1);


for arch = 1:2

for time  = 1:498

day   = textread('../archivesDay_all');
year  = textread('../archivesYear_all');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:5

depthid = str2num(readline('../3D/layersDepthID_5_iso',did));
depth = digit(depthid,4);

depth

    
    label = 'okuboweiss'

if (arch == 1)
 file = strcat('./output/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file = strcat('./output/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_00.a');
end

var = binaryread(file,idm,jdm,ijdm,depthid);

'plotting...';

 ch = figure();

 imagesc(lon,lat,var);
% [p1,p1] = contourf(lon,lat,var,50);
% set(p1,'LineStyle','none');
 axis xy;
 axis image;
 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)

% title([label,', day ',lday,', year ',lyear]);
 colorbar;
 caxis([-2*10^-9 2*10^-9])

 if(arch == 1)
  label = strcat('./plot/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a','.eps');
 else
  label = strcat('./plot/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a','.eps');
 end

 print(ch,'-dpsc2',label);

close all;

end
end
end
