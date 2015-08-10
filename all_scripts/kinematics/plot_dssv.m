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

for time  = 200:201

day   = textread('../archivesDay_all');
year  = textread('../archivesYear_all');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:1

%depthid = str2num(readline('../3D/layersDepthID_5_iso',did));
depthid = 5;
depth = digit(depthid,4);

depth

for i= 4:4
    
if(i==1)
    label = 'divergence'
end

if(i==2)
    label = 'shearing'
end

if(i==3)
    label = 'stretching'
end

if(i==4)
    label = 'vorticity'
end

if (arch == 1)
 file = strcat('./output/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file = strcat('./output/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_00.a');
end

var = binaryread(file,idm,jdm,ijdm,depthid);
var = var/(8*10^-5);

 maxvar   = 2;%quantile(var(~isnan(var)),.95);
 minvar   = -1;%quantile(var(~isnan(var)),.05);

'plotting...';

 ch = figure();

% imagesc(lon,lat,var);
 [p1,p1] = contourf(lon,lat,var,50);
 set(p1,'LineStyle','none');
 ylabel('Latitude','FontSize',15)
 xlabel('Longitude','FontSize',15)
 set(gca,'FontSize',14)
 cb = colorbar;
 set(cb, 'FontSize',14)
 axis image
 axis xy;
 axis image;
% load('OWColorMap','mycmap')
% set(ch,'Colormap',mycmap)

% title([label,', day ',lday,', year ',lyear]);
 caxis([minvar maxvar]);

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
end
