clear all

gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line1 = fgetl(gridbfid);
idm  = sscanf(line1,'%f',1);
line1 = fgetl(gridbfid);
jdm  = sscanf(line1,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region

ijdm = idm*jdm;

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

d_step = 5;
d_end = 500;
d_z = 2;

for region = 3:2:3
for arch = 1:2

for time = 1:22  

if arch == 1
 day   = textread('../../3D/archivesDay_22_h_lcs');
 year  = textread('../../3D/archivesYear_22_h_lcs');
else
 day   = textread('../../3D/archivesDay_22_l_lcs');
 year  = textread('../../3D/archivesYear_22_l_lcs');
end

lday  = digit(day(time),3);
lyear = digit(year(time),4);


for hour = 2:2

if arch == 2 && hour == 2, break, end

if hour == 1
 lhour = '00'
else
 lhour = '12'
end


clear fsleB fsleF

[X1,X2,Y1,Y2,R,lsec] = regions_lcs(region+year(time)-7,arch);

ids = X2-X1;
jds = Y2-Y1;

lon = tlon(1,X1:X2-1);
lat = tlat(Y1:Y2-1,1);

if arch == 1
 fileu = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/016_archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zu.A')
 filev = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/016_archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zv.A')
 filew = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/016_archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zw.A')
else
 fileu = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zu.A')
 filev = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zv.A')
 filew = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zw.A')
end

d_id = 0;

for did =1:d_step:d_end
 d_id = d_id + 1;
 d_depth(d_id) = d_id*d_step*d_z;

 u(:,:,d_id) = binaryread(fileu,ids,jds,ids*jds,did);
 v(:,:,d_id) = binaryread(filev,ids,jds,ids*jds,did);
 w(:,:,d_id) = binaryread(filew,ids,jds,ids*jds,did); 
end % depth

d_depth;

if arch == 1
 labelu = strcat('016_archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zu')
 labelv = strcat('016_archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zv')
 labelw = strcat('016_archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zw')
else
 labelu = strcat('archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zu')
 labelv = strcat('archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zv')
 labelw = strcat('archv.',lyear,'_',lday,'_',lhour,'_2m_',R,'_3zw')
end

csvwrite(strcat(labelu,'.csv'),u);
csvwrite(strcat(labelv,'.csv'),v);
csvwrite(strcat(labelw,'.csv'),w);

llat = strcat('lat_',lyear,'_',R,'.csv');
llon = strcat('lon_',lyear,'_',R,'.csv');

csvwrite(llat,lat);
csvwrite(llon,lon);

convert2netCDF(lat,'latitude',lon,'longitude',d_depth,'depth',u,'U',labelu,labelu);


end
end
end


end

ldepth = strcat('depth_',R,'.csv');
csvwrite(ldepth,d_depth);
