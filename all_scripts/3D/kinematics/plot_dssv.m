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


for arch = 1:1

for time = 199:201
%for time = 1:498

day   = textread('../../3D/archivesDay_all_04');
year  = textread('../../3D/archivesYear_all_04');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did = 1:1

depth = readline('../../3D/layersDepth_3',did);
depthid = str2num(readline('../../3D/layersDepthID_3',did));
depth

depth

for i = 4:4
    
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
 file = strcat('./output/high-res/',label,'_a_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file = strcat('./output/low-res/',label,'_a_l_016_archv.',lyear,'_',lday,'_00.a');
end

vort = binaryread(file,idm,jdm,ijdm,did);

vort = vort/(8*10^-5);
'plotting...';

 vort(isnan(vort)) = 0;

 ch = figure();

 imagesc(lon,lat,vort);
% [p1,p1] = contourf(lon,lat,vort,50);
% set(p1,'LineStyle','none');
 axis xy;

 axis image;

% title([label,', day ',lday,', year ',lyear]);

 load('VortColormap','mycmap')
 set(ch,'Colormap',mycmap)

 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)


 caxis([-1 1]);

 if(arch == 1)
  label = strcat('./plot/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a','.eps')
 else
  label = strcat('./plot/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a','.eps')
 end

 print(ch,'-dpsc2',label);

close all;

end
end
end
end
