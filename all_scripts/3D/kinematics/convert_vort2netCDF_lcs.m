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
d_step = 10;
d_end = 250;

for region = 7:7

[X1,X2,Y1,Y2,R,null] = regions_lcs(region,1);

lon = tlon(1,X1:X2-1);
lat = tlat(Y1:Y2-1,1);

ids = X2-X1;
jds = Y2-Y1;
ijds = ids*jds;

for arch = 1:1

for time  = 1:2

clear vort

if arch == 1
day   = textread('../archivesDay_2_h_lcs');
year  = textread('../archivesYear_2_h_lcs');
else
day   = textread('../archivesDay_2_l_lcs');
year  = textread('../archivesYear_2_l_lcs');
end

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear


label = 'vorticity';

if (arch == 1)
 file = strcat('./output/high-res/',label,'_lcs_a_h_016_archv.',lyear,'_',lday,'_',R,'_lcs_00.a');
else
 file = strcat('./output/low-res/',label,'_lcs_a_l_016_archv.',lyear,'_',lday,'_',R,'_lcs_00.a');
end

d_id = 0;
for did =1:d_step:d_end
d_id = d_id + 1;

vortt = binaryread(file,ids,jds,ijds,did);

vort(:,:,d_id) = vortt(:,:)';

end % depth

z = textread('../layersDepth_lcs');
z = z(1:d_step:d_end);

convert2netCDF(lon,'longitude',lat,'latitude',z,'depth',vort,'vort',strcat('vort_',lyear,'_',lday,'_',R),strcat('vort_',lyear,'_',lday,'_',R));

end % end day
end % end arch

end % end region
