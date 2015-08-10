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

d_step = 2;
d_end = 21;

z_id = [1, 3, 4, 5, 7, 8, 9, 12, 16, 20, 24, 28, 32, 36, 40, 48, 56, 64, 72, 80, 88]
z = z_id.*10 - 9;

for arch = 1:2
for time  = 1:2
for region = 1:2:3

clear fsleB fsleF

[X1,X2,Y1,Y2,R,lsec] = regions_lcs(region+time,arch);

lon = tlon(1,X1:X2-1);
lat = tlat(Y1:Y2-1,1);

if time == 1
 season = 'Sum'
else
 season = 'Win'
end

if arch == 1
 file1 = strcat('./output/fsle_data_',season,R,'_h.mat');
else
 file1 = strcat('./output/fsle_data_',season,R,'_l.mat');
end

did = 1
load(file1);

for did =1:1:d_end
 d_id = z_id(did);

if arch == 1
 fsleB(:,:,did) = -LiapB(:,:,d_id)';
 fsleF(:,:,did) =  LiapF(:,:,d_id)';

for i = 1:X2-X1
 for j = 1:Y2-Y1
  if (abs(LiapF(j,i,d_id)) > abs(LiapB(j,i,d_id)))
   temp(i,j) =  LiapF(j,i,d_id);
  else
   temp(i,j) = -LiapB(j,i,d_id); 
  end
 end
end
  
fsle(:,:,did) =  temp';

else
 fsleB(:,:,did) = -LiapB1(:,:,d_id)';
 fsleF(:,:,did) =  LiapF1(:,:,d_id)';

for i = 1:X2-X1
 for j = 1:Y2-Y1
  if (abs(LiapF1(j,i,d_id)) > abs(LiapB1(j,i,d_id)))
   temp(i,j) =  LiapF1(j,i,d_id);
  else
   temp(i,j) = -LiapB1(j,i,d_id);
  end
 end
end

fsle(:,:,did) =  temp';

end

end % depth


if arch == 1
labelF = strcat('fsleF_h_',season,'_',R)
labelB = strcat('fsleB_h_',season,'_',R)
labelFB = strcat('fsleFB_h_',season,'_',R)
else
labelF = strcat('fsleF_l_',season,'_',R)
labelB = strcat('fsleB_l_',season,'_',R)
labelFB = strcat('fsleFB_l_',season,'_',R)
end

%convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',fsleF,'fsleF',labelF,labelF);
%convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',fsleB,'fsleB',labelB,labelB);

csvwrite(strcat(labelF,'.csv'),fsleF);
csvwrite(strcat(labelB,'.csv'),fsleB);
csvwrite(strcat(labelFB,'.csv'),fsle);

llat = strcat('lat_',season,'_',R,'.csv');
llon = strcat('lon_',season,'_',R,'.csv');

csvwrite(llat,lat);
csvwrite(llon,lon);

ldepth = strcat('depth_',season,'_',R,'.csv');
csvwrite(ldepth,z);

end
end
end
