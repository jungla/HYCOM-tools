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

for region = 1:1

[X1,X2,Y1,Y2,R] = regions_s(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 1:2

for time  = 1:2

day   = textread('../../../3D/archivesDay_2');
year  = textread('../../../3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did = 1:2

depth = readline('../../../3D/layersDepth_4',did);
depthid = str2num(readline('../../../3D/layersDepthID_4',did));
depth

if (arch == 1)
 file   = strcat('./output/high-res/ri_h_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('../../kinematics/output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
else
 file   = strcat('./output/low-res/ri_l_016_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('../../kinematics/output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
end

Rit  = binaryread(file,idm,jdm,ijdm,depthid);
Rhot = binaryread(file1,idm,jdm,ijdm,depthid);
Vort = hycomread(file2,idm,jdm,ijdm,1);
Ro   = Vort./f;

Ri  = Rit(Y1:Y2,X1:X2);
Rho = Rhot(Y1:Y2,X1:X2);
Ro  = Ro(Y1:Y2,X1:X2);

RiRo2 = Ri.*(Ro.^2);

maxRiRo2   = 5  %quantile(RiRo2(~isnan(RiRo2)),.99);
minRiRo2   = 0 %quantile(RiRo2(~isnan(RiRo2)),.01);

[ch] = figure();

%%%%%%%%%%%%%%%%%%%%%% RiRo^2
% subplot(3,1,3)
 p1 = imagesc(lon,lat,RiRo2);
 axis xy;
% [p1,p1] = contourf(lon,lat,RiRo2N);
% set(p1,'LineStyle','none');
% load('MyColormaps','mycmap');
% set(ch,'Colormap',mycmap);
 colormap(cool);
 colorbar;

 hold on;
 [r0,r0] = contour(lon,lat,RiRo2,[1 1]);
 set(r0,'Color',[1 0 0],'LineWidth',2,'LineStyle','-','ShowText','off','LineWidth',1);

% [r4,r4] = contour(lon,lat,RiRo2,[1 1]);
% set(r4,'Color',[1 0 0],'LineWidth',0.5,'LineStyle',':','ShowText','off');

% [r1,r1] = contour(lon,lat,Ri,[0.25 0.25]);
% set(r1,'Color',[0.5 0.5 0.5],'LineWidth',0.5,'LineStyle','-','ShowText','off');

% [r2,r2] = contour(lon,lat,Ri,[1 1]);
% set(r2,'Color',[0 0 0],'LineWidth',0.5,'LineStyle','-','ShowText','off');

% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);

 caxis([minRiRo2 maxRiRo2])

 title('Bu^2','FontSize',24)
 ylabel('Latitude','FontSize',24)
 xlabel('Longitude','FontSize',24)
 set(gca,'FontSize',24)
 cb = colorbar;
 set(cb, 'FontSize',24)
 axis image


 if (arch==1)
  label = strcat('./plot/high-res/MLI_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
 else
  label = strcat('./plot/low-res/MLI_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
 end 

 'saving...'
 print(ch,'-dpsc2',label)

 close all;

end % depth
end % end day
end % end arch

end % end region
