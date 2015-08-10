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

for region = 1:4

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

for arch = 1:2

for time  = 1:49

day   = textread('../../archivesDay');
year  = textread('../../archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:4

depth = readline('../../layersDepth_4',did);
depthid = str2num(readline('../../layersDepthID_4',did));
depth

depth

if (arch == 1)
 file1  = strcat('../../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
else
 file1  = strcat('../../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
end

Rhot = binaryread(file1,idm,jdm,ijdm,depthid);

Rho = Rhot(Y1:Y2,X1:X2);

Rho = smooth2(Rho,sm);

 gRx = cdxy(Rho,pscx,0);
 gRy = cdxy(Rho,pscy,1);

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

 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
% title('|\nabla^h\rho|')
 colorbar;
 axis image
 axis xy;

 if (arch == 1)
  label = strcat('./plot/high-res/gradRho_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
 else
  label = strcat('./plot/low-res/gradRho_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
 end 

 'saving...'
 print(ch,'-dpsc2',label)

 close all;

end % depth
end % end day
end % end arch

end % end region
