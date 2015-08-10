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

for time  = 1:2; %dayi:dstep:dayf-dstep

day   = textread('../../../3D/archivesDay_2');
year  = textread('../../../3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:4

depth = readline('../../../3D/layersDepth_4',did);
depthid = str2num(readline('../../../3D/layersDepthID_4',did));
depth

if (arch == 1)
 file0  = strcat('../../../3D/kinematics/output/high-res/shearing_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file1  = strcat('../../../3D/kinematics/output/high-res/stretching_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file2  = strcat('../../../3D/kinematics/output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file3  = strcat('../../../3D/stratification/Ri/output/high-res/ri_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file0  = strcat('../../../3D/kinematics/output/low-res/shearing_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file1  = strcat('../../../3D/kinematics/output/low-res/stretching_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file2  = strcat('../../../3D/kinematics/output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 file3  = strcat('../../../3D/stratification/Ri/output/low-res/ri_l_016_archv.',lyear,'_',lday,'_00.a');
end

Sht  = hycomread(file0,idm,jdm,ijdm,1);
Stt  = hycomread(file1,idm,jdm,ijdm,1);
Vort = hycomread(file2,idm,jdm,ijdm,1);

fs  = f(Y1:Y2,X1:X2);
Sh  = Sht(Y1:Y2,X1:X2);
St  = Stt(Y1:Y2,X1:X2);
Vor = Vort(Y1:Y2,X1:X2);

% A-S
SA = Vor + fs - sqrt(Sh.^2 + St.^2);

  maxSA   = quantile(SA(~isnan(SA)),.99);
  minSA   = quantile(SA(~isnan(SA)),.01);

 [ch] = figure();

% load('OWColorMap.mat','mycmap')
% set(ch,'Colormap',mycmap)

%%%%%%%%%%%%%%%%%%%%%% Ri > 1
% subplot(3,1,1)
%% [p1,p1] = contourf(lon,lat,RiN);
% p1 = imagesc(lon,lat,RiN);
% caxis([minRi maxRi])
%% set(p1,'LineStyle','none');
%
% hold on;
% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
%
% title('Ri')
% xlabel('Longitude','FontSize',12)
% ylabel('Latitude','FontSize',12)
% colorbar;
% axis image

%%%%%%%%%%%%%%%%%%%% Ro < 1
% subplot(3,1,2)
% p1 = imagesc(lon,lat,RoN);
% caxis([minRo maxRo])
%% set(p1,'LineStyle','none');
%
% hold on;
% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
%
% title('Ro');
% xlabel('Longitude','FontSize',12);
% ylabel('Latitude','FontSize',12)
% colorbar;
% axis image


%%%%%%%%%%%%%%%%%%%%% SA = 0

% subplot(3,1,3)
%
 p0 = imagesc(lon,lat,SA);
 caxis([minSA maxSA])
 axis xy;
 hold on;

% [p1,p1] = contour(lon,lat,SA);
% set(p1,'Color',[0 0 0]);

 [r0,r0] = contour(lon,lat,SA,[0 0]);
 set(r0,'Color',[0 0 0],'LineWidth',1,'LineStyle','-','ShowText','off');

% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);

 title('A-S','FontSize',18)
 ylabel('Latitude','FontSize',13)
 xlabel('Longitude','FontSize',13)
 set(gca,'FontSize',13)
 cb = colorbar;
 set(cb, 'FontSize',13)
 axis image


 if (arch==1)
  label = strcat('./plot/high-res/AAI_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
 else
  label = strcat('./plot/low-res/AAI_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
 end 

 'saving...'
 print(ch,'-dpsc2',label)

 close all;

end % depth
end % end day
end % end arch

end % end region
