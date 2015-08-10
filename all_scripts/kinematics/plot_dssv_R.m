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

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

for arch = 1:2

for time  = 1:2

day   = textread('../3D/archivesDay_2');
year  = textread('../3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for region = 1:1

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for did =1:1

%depthid = str2num(readline('../3D/layersDepthID_5_iso',did));
depthid = 1;
depth = digit(depthid,4);

depth

for i=4:4
    
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

vart = binaryread(file,idm,jdm,ijdm,depthid);
var = vart(Y1:Y2,X1:X2);
var = var./(8*10^-5);

 maxvar   = 1;
 minvar   = -1;

'plotting...';

 ch = figure();

% imagesc(lon,lat,var);
 [p1,p1] = contourf(lon,lat,var,50);
 set(p1,'LineStyle','none');
 axis xy;
 load('VortColormap','mycmap')
 set(ch,'Colormap',mycmap)

% title('\zeta','FontSize',18)
 ylabel('Latitude','FontSize',15)
 xlabel('Longitude','FontSize',15)
 set(gca,'FontSize',15)
 cb = colorbar;
 set(cb, 'FontSize',15)
 axis image

% title([label,', day ',lday,', year ',lyear]);
 caxis([minvar maxvar]);

 if(arch == 1)
  label = strcat('./plot/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_',depth,'_',R,'_00.a','.eps')
 else
  label = strcat('./plot/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_',depth,'_',R,'_00.a','.eps')
 end

 print(ch,'-dpsc2',label);

close all;

end
end
end
end
end
