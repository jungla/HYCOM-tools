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

depth = readline('../../layersDepth_4',did);
depthid = str2num(readline('../../layersDepthID_4',did));
depth

if (arch == 1)
 file0  = strcat('../../kinematics/output/high-res/shearing_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file1  = strcat('../../kinematics/output/high-res/stretching_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file3  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
else
 file0  = strcat('../../kinematics/output/low-res/shearing_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file1  = strcat('../../kinematics/output/low-res/stretching_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file3  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
end


Sht  = hycomread(file0,idm,jdm,ijdm,1);
Stt  = hycomread(file1,idm,jdm,ijdm,1);
Rhot = binaryread(file3,idm,jdm,ijdm,depthid);

fs  = f(Y1:Y2,X1:X2);
Sh  = Sht(Y1:Y2,X1:X2);
St  = Stt(Y1:Y2,X1:X2);
Rho = Rhot(Y1:Y2,X1:X2);

% S
S = sqrt(Sh.^2 + St.^2);

SN = S./fs;

%RoN(Ro > 0) = NaN;


 [ch] = figure();
% orient landscape;

% maxS   = quantile(SN(~isnan(SN)),.95);
% minS   = quantile(SN(~isnan(SN)),.5);

 minS   = 0.25;
 maxS   = 0.67;

%%%%%%%%%%%%%%%%%%%%% S

 [p1,p1] = contourf(lon,lat,SN,50);
% p1 = imagesc(lon,lat,SN);
 axis xy;
 colorbar;
 set(p1,'LineStyle','none');
 caxis([minS maxS]);
 colorbar;
 hold on;

 [r0,r0] = contour(lon,lat,SN,[0 0]);
 set(r0,'Color',[0 0 0],'LineStyle','-','ShowText','off','LineWidth',1);


% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);

 title('S','FontSize',18)
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)
 axis image


if (arch == 1)
 label = strcat('./plot/high-res/S_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/S_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
