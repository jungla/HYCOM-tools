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

for arch = 1:1

for time  = 1:1

clear Rho

day   = textread('../archivesDay_2');
year  = textread('../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:4

depth = readline('../layersDepth_4',did);
depthid = str2num(readline('../layersDepthID_4',did));
depth

label = 'vorticity';

if (arch == 1)
 file = strcat('./output/dssv/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
else
 file = strcat('./output/dssv/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
end


Rhot = binaryread(file,idm,jdm,ijdm,1);

Rho(:,:,did) = Rhot(Y1:Y2,X1:X2)';

end % depth

z = textread('../layersDepth_4');

convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',Rho,'vort',strcat('vort_',lyear,'_',lday,'_',R),strcat('vort_',lyear,'_',lday,'_',R));

end % end day
end % end arch

end % end region
