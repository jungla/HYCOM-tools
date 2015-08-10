clear all;

x1 = -72.02
x2 = -55.86
y1 = 30.162
y2 = 33.442

%x1 = -81.44
%x2 = -50
%y2 = 45.72
%y1 = 28.78 

date  = textread('dates_SST_2012');
itime = 0;

dayi = 1;
dayf = 362;
days = 2;

file = '../topo0.02/regional.grid.a';

idm = 1573;
jdm = 1073;
ijdm = idm*jdm;

tlonh = hycomread(file,idm,jdm,ijdm,1);
tlath = hycomread(file,idm,jdm,ijdm,2);

[X1,X2,Y1,Y2,R] = regions(1);

lonh = tlonh(1,X1:X2);
lath = tlath(Y1:Y2,1);

for time  = dayi:days:dayf

itime = itime+1;
ldate = digit(date(time),4);
lday  = digit(time,3);
lyear = '0008';

%% read netCDF

file = strcat('/tamay/mensa/SST/2012',ldate,'-JPL_OUROCEAN-L4UHfnd-GLOB-v01-fv01_0-G1SST.nc')

ncid = netcdf.open(file);
tlon = netcdf.getVar(ncid,1);
tlat = netcdf.getVar(ncid,2);
tSST = netcdf.getVar(ncid,3);
tmask = netcdf.getVar(ncid,4);

% get some Attributes for sst
varid = netcdf.inqVarID(ncid,'analysed_sst');
fvalue = double(netcdf.getAtt(ncid,varid,'_FillValue'));
offset = double(netcdf.getAtt(ncid,varid,'add_offset'));
scale  = double(netcdf.getAtt(ncid,varid,'scale_factor'));

% get some Attributes for mask
% attname = netcdf.inqAttName(ncid,varid,5)
%varid = netcdf.inqVarID(ncid,'mask')

netcdf.close(ncid);

lon = 360 + double(tlon(tlon>=x1 & tlon<=x2));
lat = double(tlat(tlat>=y1 & tlat<=y2));
SST = double(tSST(tlon>=x1 & tlon<=x2,tlat>=y1 & tlat<=y2)');
mask= double(tmask(tlon>=x1 & tlon<=x2,tlat>=y1 & tlat<=y2));
clear tSST tmask

SST(SST == fvalue) = NaN;
SST(SST == 0) = NaN;

SST = SST.*scale+offset-273.15;
SST = smooth2(SST,2);

[gRx,gRy] = gradient(SST,lon,lat);

gradSST = sqrt(gRx.^2 + gRy.^2);
mSST(itime,1) = mean(gradSST(~isnan(gradSST)));

%%%%%%%%%%%%%%%%%% read HYCOM

file = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.0008_',lday,'_12.a')

SSTt = hycomread(file,idm,jdm,ijdm,1*5+10);

SST = SSTt(Y1:Y2,X1:X2);
SST = smooth2(SST,2);

[gRx,gRy] = gradient(SST,lonh,lath);

gradSST = sqrt(gRx.^2 + gRy.^2);
mSSTh(itime) = mean(gradSST(~isnan(gradSST)));

end

% smooth
for t = 2:size(mSST,1)-1
 mSST(t,2) = (mSST(t-1,1)+mSST(t,1)+mSST(t+1,1))/3;
end
mSST(size(mSST,1),2) = (mSST(size(mSST,1),1)+mSST(size(mSST,1)-1,1))*0.5;
mSST(1,2) = (mSST(1,1)+mSST(2,1))*0.5;

[ch] = figure();
hold on
p0 = plot(dayi:days:dayf,mSST(:,1),'Color',[0.8 0.8 0.8],'LineWidth',1.2);
p1 = plot(dayi:days:dayf,mSST(:,2),'k','LineWidth',1.2);
p2 = plot(dayi:days:dayf,mSSTh,'b','LineWidth',1.2);
ylabel('mean(|\nabla SST|)','FontSize',14)
xlabel('Time (days)','FontSize',14)

set(gca,'XTick', 1:30:itime*2);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',14)

%title('trend mean(|\nabla SST|)','FontSize',16)

label = strcat('./plot/gradSST_JPL.eps')
print(ch,'-dpsc2',label);
close all;

