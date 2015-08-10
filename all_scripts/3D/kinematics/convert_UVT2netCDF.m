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

lon = tlon(Y1:Y2,X1:X2);
lat = tlat(Y1:Y2,X1:X2);

ids = X2-X1+1;
jds = Y2-Y1+1;

for arch = 1:1

for time  = 1:1

clear Rho

day   = textread('../archivesDay_2');
year  = textread('../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:20

depth = readline('../layersDepth_all',did);
depthid = str2num(readline('../layersDepthID_all',did));
depth

if (arch == 1)
 file0 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zr.A ');
 file1 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zs.A ');
 file2 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zt.A ');
 file3 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zu.A ');
 file4 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zv.A ');
 file5 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zw.A ');
else
 file0 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zr.A ');
 file1 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zs.A ');
 file2 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zt.A ');
 file3 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zu.A ');
 file4 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zv.A ');
 file5 = strcat('/tamay/mensa/hycom/GSa0.02_3Da/016_archv.0008_001_12_a_3zw.A ');
end

rt = binaryread(file0,idm,jdm,ijdm,did);
r(time,did,:,:) = rt(Y1:Y2,X1:X2);

st = binaryread(file1,idm,jdm,ijdm,did);
s(time,did,:,:) = st(Y1:Y2,X1:X2);

tt = binaryread(file2,idm,jdm,ijdm,did);
t(time,did,:,:) = tt(Y1:Y2,X1:X2);

ut = binaryread(file3,idm,jdm,ijdm,did);
u(time,did,:,:) = ut(Y1:Y2,X1:X2);

vt = binaryread(file4,idm,jdm,ijdm,did);
v(time,did,:,:) = vt(Y1:Y2,X1:X2);

wt = binaryread(file5,idm,jdm,ijdm,did);
w(time,did,:,:) = wt(Y1:Y2,X1:X2);

end % depth

% create vars for NEMO archives

z = textread('../layersDepth_all');

depthu = z(1:20,1);
depthv = z(1:20,1);
time_counter = 1:time;

y = 1:jds;
x = 1:ids;
nav_lat = lat;
nav_lon = lon;

time_counter(time_counter)

vozocrtx =  u;                    %(time_counter, depthu, y, x)   % velocity
sozotaux(time_countr,y,x) = 0;    %(time_countr, y, x)            % stress
sozotauxwo(time_countr,y,x) = 0;  %(time_counter, y, x)           % stress

convert2NEMO_U(lon,lat,depthu,time_counter,vozocrtx,sozotaux,sozotauxwo, strcat('U_',lyear,'_',lday,'_',R),strcat('U_',lyear,'_',lday,'_',R));

vomecrty =  v;
sometauy(time_countr,y,x) = 0;
sometauywo(time_countr,y,x) = 0;
convert2NEMO_V(lon,lat,depthv,time_counter,vomecrty,sometauy,sometauywo,strcat('V_',lyear,'_',lday,'_',R),strcat('V_',lyear,'_',lday,'_',R));



end % end day
end % end arch

end % end region
