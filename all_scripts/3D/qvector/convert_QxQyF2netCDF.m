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


dayi = 1;    % variables for day loop
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

clear Qx Qy F

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
 file1   = strcat('./output/high-res/qvectorx_h_016_archv.',lyear,'_',lday,'_00.a');
 file2   = strcat('./output/high-res/qvectory_h_016_archv.',lyear,'_',lday,'_00.a');
 file3   = strcat('./output/high-res/F_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file1   = strcat('./output/low-res/qvectorx_l_016_archv.',lyear,'_',lday,'_00.a');
 file2   = strcat('./output/low-res/qvectory_l_016_archv.',lyear,'_',lday,'_00.a');
 file3   = strcat('./output/low-res/F_l_016_archv.',lyear,'_',lday,'_00.a');
end

Qxt  = binaryread(file,idm,jdm,ijdm,depthid);
Qyt  = binaryread(file1,idm,jdm,ijdm,depthid);
Ft   = hycomread(file2,idm,jdm,ijdm,depthid);

Qx(:,:,did) = Qxt(Y1:Y2,X1:X2)';
Qy(:,:,did)  = Qyt(Y1:Y2,X1:X2)';
F(:,:,did)  = abs(Ft(Y1:Y2,X1:X2))';

end % depth

z = textread('../layersDepth_11');

if (arch == 1)
 lQx = strcat('Qx_h_',lyear,'_',lday,'_',R);
 lQy = strcat('Qy_h_',lyear,'_',lday,'_',R);
 lF = strcat('F_h_',lyear,'_',lday,'_',R);
else
 lQx = strcat('Qx_l_',lyear,'_',lday,'_',R);
 lQy = strcat('Qy_l_',lyear,'_',lday,'_',R);
 lF = strcat('F_l_',lyear,'_',lday,'_',R);
end

 Qx = flipdim(Qx,3);
 Qy = flipdim(Qy,3);
 F = flipdim(F,3);

 z = flipdim(z,1);
 
 convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',Qy, 'Qy' ,lQy,lQy);
 convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',Qx, 'Qx' ,lQx,lQx);
 convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',F, 'F' ,lF,lF);

end % end day
end % end arch

end % end region
