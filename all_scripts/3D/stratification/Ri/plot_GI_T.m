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

day   = textread('../../archivesDay_2');
year  = textread('../../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:4

depth   = readline('../../layersDepth_4',did);
depthid = str2num(readline('../../../3D/layersDepthID_4',did));
depth

if (arch == 1)
 file   = strcat('./output/high-res/ri_h_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('../../kinematics/output/dssv/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
else
 file   = strcat('./output/low-res/ri_l_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('./../kinematics/output/dssv/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
end

Rit  = binaryread(file,idm,jdm,ijdm,depthid);

Ri  = Rit(Y1:Y2,X1:X2);

 minRi   = quantile(Ri(~isnan(Ri)),.1);
 maxRi   = quantile(Ri(~isnan(Ri)),.9);

 [ch] = figure();

%%%%%%%%%%%%%%%%%%%%%% Ri < 0
 p1 = imagesc(lon,lat,Ri);
 caxis([minRi maxRi])
 colormap('hot');
 colorbar;
 hold on;
 [r1,r1] = contour(lon,lat,Ri,[0 0]);
 set(r1,'Color',[1 1 1],'LineStyle','-','ShowText','off');

% title('Ri < 0')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/GI_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/GI_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
