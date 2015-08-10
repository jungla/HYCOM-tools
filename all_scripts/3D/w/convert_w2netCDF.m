clear all;

gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
ijdm = idm*jdm;

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

omega  = 7.2921150*10^-5;
f(:,:) = zeros(jdm,idm);
f(:,:) = 2*omega*sin(tlat(:,:)*pi/90);

dayi = 1;    % vawables for day loop
dayf = 50;  %
dstep = 1;   %

maxr = 1;
minr = -1;
maxtr = -10;
mintr = 10;

N = 22;

for region = 1:4

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 1:2

for time  = 1:2

clear w

day   = textread('../archivesDay_2');
year  = textread('../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:11

depth = readline('../layersDepth_11',did);
depthid = str2num(readline('../layersDepthID_11',did));
depth

if (arch == 1)
 file  = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zw.A');
else
 file  = strcat('../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zw.A');
end


wt  = binaryread(file,idm,jdm,ijdm,depthid);
w(:,:,did)  = wt(Y1:Y2,X1:X2)';

end % depth

z = textread('../layersDepth_11');

if (arch == 1)
 lw = strcat('w_h_',lyear,'_',lday,'_',R);
else
 lw = strcat('w_l_',lyear,'_',lday,'_',R);
end

 w = flipdim(w,3);

 z = flipdim(z,1);
 
 convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',w, 'w' ,lw,lw);

end % end day
end % end arch

end % end region
