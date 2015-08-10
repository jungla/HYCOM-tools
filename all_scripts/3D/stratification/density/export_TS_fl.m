clear; close all;
%%%% dimensions  
gridbfid=fopen('../../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);


for time = 1:2

day   = textread('../../archivesDay_fl');
year  = textread('../../archivesYear_fl');

lday   = digit(day(time),3)
lyear  = digit(year(time),4)

[X1,X2,Y1,Y2,R] = regions_fl(1,time)
[x1,x2,y1,y2,R] = regions_fl_box(time)

ids = X2-X1;
jds = Y2-Y1; 
ijds = ids*jds;

lon = tlon(1,X1+1:X2-1);
lat = tlat(Y1:Y2-1,1);

slon = lon(1,x1:x2-1);
slat = lat(y1:y2-1,1);

alon = tlon(y1:y2-1,x1:x2-1);
alat = tlat(y1:y2-1,x1:x2-1);

hd = '00'
d_step = 5


for t = 1:1

if time == 1
 d_end = 141;
else
 d_end = 201;
end

clear Ts Ss Us Vs Ws

file1 = strcat('../../../../GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_',hd,'_2m_FL_3zt.A');
file2 = strcat('../../../../GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_',hd,'_2m_FL_3zs.A');
file3 = strcat('../../../../GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_',hd,'_2m_FL_3zu.A');
file4 = strcat('../../../../GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_',hd,'_2m_FL_3zv.A');
file5 = strcat('../../../../GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_',hd,'_2m_FL_3zw.A');

d_id = 0;

for did = 1:d_step:d_end

d_id = d_id + 1;

T = binaryread(file1,ids,jds,ijds,did);
S = binaryread(file2,ids,jds,ijds,did);

U = binaryread(file3,ids,jds,ijds,did);
V = binaryread(file4,ids,jds,ijds,did);
W = binaryread(file5,ids,jds,ijds,did);

T = T(:,2:end);
S = S(:,2:end);

U = U(:,2:end);
V = V(:,2:end);
W = W(:,2:end);

%T = smooth2(T,1);
%S = smooth2(S,1);

Ts(:,:,d_id) = T(y1:y2-1,x1:x2-1);
Ss(:,:,d_id) = S(y1:y2-1,x1:x2-1);

Us(:,:,d_id) = U(y1:y2-1,x1:x2-1);
Vs(:,:,d_id) = V(y1:y2-1,x1:x2-1);
Ws(:,:,d_id) = W(y1:y2-1,x1:x2-1);

%smooth2(Ts,1);
%smooth2(Ss,1);

end

z = textread('../../layersDepth_all_l01');
z = z(1:d_step:d_end);

'exporting...'

labelT = strcat('T_',lyear,'_',lday,'_',R);
labelS = strcat('S_',lyear,'_',lday,'_',R);

labelU = strcat('U_',lyear,'_',lday,'_',R);
labelV = strcat('V_',lyear,'_',lday,'_',R);
labelW = strcat('W_',lyear,'_',lday,'_',R);

convert2netCDF(slat,'latitude',slon,'longitude',z,'depth',Ss,'S',labelS,labelS);
convert2netCDF(slat,'latitude',slon,'longitude',z,'depth',Ts,'T',labelT,labelT);

csvwrite(strcat(labelT,'.csv'),Ts(:,:,:)); %I could use only the first layer. they are all the same...
csvwrite(strcat(labelS,'.csv'),Ss(:,:,:));

csvwrite(strcat(labelU,'.csv'),Us(:,:,:));
csvwrite(strcat(labelV,'.csv'),Vs(:,:,:));
csvwrite(strcat(labelW,'.csv'),Ws(:,:,:));

llat = strcat('lat_',lyear,'_',lday,'_',R,'.csv');
llon = strcat('lon_',lyear,'_',lday,'_',R,'.csv');

csvwrite(llat,alat);
csvwrite(llon,alon);

ldepth = strcat('depth_',lyear,'_',lday,'_',R,'.csv');
csvwrite(ldepth,z);

end
end
