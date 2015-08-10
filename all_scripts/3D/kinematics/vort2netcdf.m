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

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

lon = tlon(1,:);
lat = tlat(:,1);

lon = reshape(lon,idm,1);

omega  = 7.2921150*10^-5;
f(:,:) = zeros(jdm,idm);
f(:,:) = 2*omega*sin(tlat(:,:)*pi/90);

for arch = 1:2

for time  = 1:2

day   = textread('../../3D/archivesDay_2');
year  = textread('../../3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:22

depth = readline('../../3D/layersDepth',did);
depthid = str2num(readline('../../3D/layersDepthID',did));
depth

depthL(did) = str2num(depth);

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
 file = strcat('./output/dssv/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
else
 file = strcat('./output/dssv/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
end

vort = hycomread(file,idm,jdm,ijdm,1);

vort = vort./f;
'plotting...';

vort3D(:,:,depthid) = vort;

 if(arch == 1)
  label = strcat('./output/dssv/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 else
  label = strcat('./output/dssv/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 end

end
end

d3bin2netCDF(lon,'lon',lat,'lat',depthL,'depth',vort3D,'vorticity',label,'vorticity');

end
end
