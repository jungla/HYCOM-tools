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

dayi = 1;    % variables for day loop
dayf = 50;  %
dstep = 1;   %

maxr = 1;
minr = -1;
maxtr = -10;
mintr = 10;


for region = 5:5

[X1,X2,Y1,Y2,R] = regions_s(1);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

for arch = 1:1

for time  = 1:2

day   = textread('../../archivesDay_2');
year  = textread('../../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for sm = 2:2

for did =1:2

depth = readline('../../layersDepth_2',did);
depthid = str2num(readline('../../layersDepthID_2',did));
depth


if (arch == 1)
 file1  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_23_3zr.a');
else
 file1  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_23_3zr.a');
end

Rhot = binaryread(file1,idm,jdm,ijdm,depthid);

Rho = Rhot(Y1:Y2,X1:X2);

Rho = smooth2(Rho,sm);

[gRx,gRy] = gradient(Rho,lon,lat);

 gradRho = sqrt(gRx.^2 + gRy.^2);

  maxRho   = quantile(gradRho(~isnan(gradRho)),.9);
  minRho   = quantile(gradRho(~isnan(gradRho)),.1);

 [ch] = figure();
% orient landscape;

 p1 = imagesc(lon,lat,gradRho);
 caxis([minRho maxRho]);
% set(p1,'LineStyle','none');

% hold on;
% [p2,p2] = contour(lon,lat,gradRho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);

 ylabel('Latitude','FontSize',14)
 xlabel('Longitude','FontSize',14)
 title(strcat('pass:',num2str(sm),' mean(|\nabla \rho|):',num2str(mean(gradRho(~isnan(gradRho))))),'FontSize',16)
 colorbar;
 axis image
 axis xy;

 if (arch == 1)
  label = strcat('./plot/high-res/gradRho_',num2str(sm),'_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
 else
  label = strcat('./plot/low-res/gradRho_',num2str(sm),'_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
 end 

 'saving...'
 print(ch,'-dpsc2',label)

 close all;

end % smooth
end % depth
end % end day
end % end arch

end % end region
