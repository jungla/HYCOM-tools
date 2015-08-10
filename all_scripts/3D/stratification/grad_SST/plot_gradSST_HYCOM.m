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

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

for arch = 1:1

for time  = 1:99

day   = textread('../../archivesDay');
year  = textread('../../archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for sm = 2:2

for did = 1:5

if (arch == 1)
 file0  = strcat('../../../../GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
else
 file0  = strcat('../../../../GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
end

SSTt = hycomread(file0,idm,jdm,ijdm,did*5+10);

SST = SSTt(Y1:Y2,X1:X2);

SST = smooth2(SST,sm);

[gRx,gRy] = gradient(SST,lon,lat);

 gradSST = sqrt(gRx.^2 + gRy.^2);

  maxSST   = quantile(gradSST(~isnan(gradSST)),.9);
  minSST   = quantile(gradSST(~isnan(gradSST)),.1);

 [ch] = figure();
% orient landscape;

 p1 = imagesc(lon,lat,gradSST);
 caxis([minSST maxSST]);
% set(p1,'LineStyle','none');

% hold on;
% [p2,p2] = contour(lon,lat,gradSST);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);

 ylabel('Latitude','FontSize',14)
 xlabel('Longitude','FontSize',14)
 title(strcat(' mean(|\nabla SST|):',num2str(mean(gradSST(~isnan(gradSST))))),'FontSize',16)
 colorbar;
 axis image
 axis xy;

 if (arch == 1)
  label = strcat('./plot/high-res/gradSST_',num2str(did),'_',lyear,'_',lday,'_h_',R,'_H.eps')
 else
  label = strcat('./plot/low-res/gradSST_',num2str(did),'_',lyear,'_',lday,'_l_',R,'_H.eps')
 end 

 'saving...'
 print(ch,'-dpsc2',label)

 close all;

end % smooth
end % depth
end % end day
end % end arch

end % end region
