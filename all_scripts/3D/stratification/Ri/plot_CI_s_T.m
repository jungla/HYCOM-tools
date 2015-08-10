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

[X1,X2,Y1,Y2,R] = regions_s(region);

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
 file2  = strcat('../../kinematics/output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
else
 file2  = strcat('../../kinematics/output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
end

CIt  = binaryread(file2,idm,jdm,ijdm,1);
CIt = CIt./f;
CI  = CIt(Y1:Y2,X1:X2);

 minCI   = min(CI(~isnan(CI)));%quantile(CI(~isnan(CI)),.01);
 maxCI   = max(CI(~isnan(CI)));%quantile(CI(~isnan(CI)),.99);

 [ch] = figure();

%%%%%%%%%%%%%%%%%%%%%% CI < 0
 p1 = imagesc(lon,lat,CI);
 caxis([minCI maxCI])
 axis xy;

% title('CI < 0')
 title('Ro','FontSize',18)
 ylabel('Latitude','FontSize',13)
 xlabel('Longitude','FontSize',13)
 set(gca,'FontSize',13)
 cb = colorbar;
 set(cb, 'FontSize',13)
 axis image

 hold on;
 [r1,r1] = contour(lon,lat,CI,[-1 -1]);
 set(r1,'Color',[0 0 0],'LineStyle','-','ShowText','off','LineWidth',1.5);

if (arch == 1)
 label = strcat('./plot/high-res/CI_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/CI_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
