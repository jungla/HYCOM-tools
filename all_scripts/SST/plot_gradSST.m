clear all;

x1 = -72.02
x2 = -55.86
y1 = 30.162
y2 = 33.442

%x1 = -81.44
%x2 = -50
%y2 = 45.72
%y1 = 28.78 

%for time  = 1:1

lday   = '0201';

file = strcat('/tamay/mensa/SST/2011',lday,'-JPL_OUROCEAN-L4UHfnd-GLOB-v01-fv01_0-G1SST.nc')

ncid = netcdf.open(file);
tlon = netcdf.getVar(ncid,1);
tlat = netcdf.getVar(ncid,2);
tSST = netcdf.getVar(ncid,3);
tmask = netcdf.getVar(ncid,4);

% get some Attributes for sst
varid = netcdf.inqVarID(ncid,'analysed_sst')
fvalue = double(netcdf.getAtt(ncid,varid,'_FillValue'))
offset = double(netcdf.getAtt(ncid,varid,'add_offset'))
scale  = double(netcdf.getAtt(ncid,varid,'scale_factor'))

% get some Attributes for mask
% attname = netcdf.inqAttName(ncid,varid,5)
%varid = netcdf.inqVarID(ncid,'mask')

netcdf.close(ncid);

idm = size(tlat,1)-1
jdm = size(tlon,1)-1

lon = 360 + double(tlon(tlon>=x1 & tlon<=x2));
lat = double(tlat(tlat>=y1 & tlat<=y2));
SST = double(tSST(tlon>=x1 & tlon<=x2,tlat>=y1 & tlat<=y2)');
mask= double(tmask(tlon>=x1 & tlon<=x2,tlat>=y1 & tlat<=y2));

SST(SST == fvalue) = NaN;
SST(SST == 0) = NaN;

SST = SST.*scale+offset-273.15;

[gRx,gRy] = gradient(SST,lon,lat);

gradSST = sqrt(gRx.^2 + gRy.^2);

maxSST   = quantile(gradSST(~isnan(gradSST)),.9);
minSST   = quantile(gradSST(~isnan(gradSST)),.1);



[ch] = figure();
imagesc(lon,lat,gradSST);
ylabel('Latitude','FontSize',14)
xlabel('Longitude','FontSize',14)
title(strcat('mean(|\nabla SST|):',num2str(mean(gradSST(~isnan(gradSST))))),'FontSize',16)
axis image;
colorbar;
caxis([minSST maxSST]);

label = strcat('./plot/gradSST_',lday,'.eps')
print(ch,'-dpsc2',label);
close all;
%end

