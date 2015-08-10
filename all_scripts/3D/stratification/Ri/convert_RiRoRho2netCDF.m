clear all;

gridbfid=fopen('../../../topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
ijdm = idm*jdm;

file = '../../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

omega  = 7.2921150*10^-5;
f(:,:) = zeros(jdm,idm);
f(:,:) = 2*omega*sin(tlat(:,:)*pi/90);

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

clear Rho Ri Ro

day   = textread('../../archivesDay_2');
year  = textread('../../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:11

depth = readline('../../layersDepth_11',did);
depthid = str2num(readline('../../layersDepthID_11',did));
depth


if (arch == 1)
 file   = strcat('./output/high-res/ri_h_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('../../kinematics/output/dssv/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
else
 file   = strcat('./output/low-res/ri_l_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('../../kinematics/output/dssv/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
end

Rit  = binaryread(file,idm,jdm,ijdm,depthid);
Rhot = binaryread(file1,idm,jdm,ijdm,depthid);
Vort = hycomread(file2,idm,jdm,ijdm,1);
Rot  = Vort./f;

Ri(:,:,did)  = Rit(Y1:Y2,X1:X2)';
Rho(:,:,did) = Rhot(Y1:Y2,X1:X2)';
Ro(:,:,did)  = abs(Rot(Y1:Y2,X1:X2))';
RiRo2 = Ri.*Ro.^2;

end % depth

z = textread('../../layersDepth_11');

if (arch == 1)
 lRi = strcat('Ri_h_',lyear,'_',lday,'_',R);
 lRo = strcat('Ro_h_',lyear,'_',lday,'_',R);
 lRho = strcat('Rho_h_',lyear,'_',lday,'_',R);
 lRiRo2 = strcat('RiRo2_h_',lyear,'_',lday,'_',R);
else
 lRi = strcat('Ri_l_',lyear,'_',lday,'_',R);
 lRo = strcat('Ro_l_',lyear,'_',lday,'_',R);
 lRho = strcat('Rho_l_',lyear,'_',lday,'_',R);
 lRiRo2 = strcat('RiRo2_l_',lyear,'_',lday,'_',R);
end

 Rho = flipdim(Rho,3);
 Ro = flipdim(Ro,3);
 Ri = flipdim(Ri,3);
 RiRo2 = flipdim(RiRo2,3);

 z = flipdim(z,1);
 
 convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',Ri, 'Ri' ,lRi,lRi);
 convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',Ro, 'Ro' ,lRo,lRo);
 convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',Rho, 'Rho' ,lRho,lRho);
 convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',RiRo2, 'RiRo2' ,lRiRo2,lRiRo2);

end % end day
end % end arch

end % end region
