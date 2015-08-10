clear all;

gridbfid=fopen('../../../topo0.02/regional.grid.b','r');
line1 = fgetl(gridbfid);
idm  = sscanf(line1,'%f',1);
line1 = fgetl(gridbfid);
jdm  = sscanf(line1,'%f',1);
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

N = 22;

for region = 1:1

[X1,X2,Y1,Y2,R] = regions_s(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 1:1

for time  = 1:2

day   = textread('../../../3D/archivesDay_2');
year  = textread('../../../3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:2

depth = readline('../../../3D/layersDepth_4',did);
depthid = str2num(readline('../../../3D/layersDepthID_4',did));
depth

if (arch == 1)
 file1  = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
else
 file1  = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
end

Rhot = binaryread(file1,idm,jdm,ijdm,depthid);

Rho = Rhot(Y1:Y2,X1:X2);


 [ch] = figure();
% orient landscape;

 maxRho   = quantile(Rho(~isnan(Rho)),.95);
 minRho   = quantile(Rho(~isnan(Rho)),.05);

%%%%%%%%%%%%%%%%%%%%% Rho
 [p1,p1] = contourf(lon,lat,Rho,50);
% p1 = imagesc(lon,lat,Ro);
 axis xy;
 set(p1,'LineStyle','none');
 caxis([minRho maxRho]);
 colorbar;
% hold on;
% caxis([-1 2])

if time == 2
 l1 = 32.7;
 text(lon(1,1)+0.1,l1+0.1, 'A','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');
 text(lon(1,end)-0.1,l1+0.1, 'A''','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');
else
 l1 = 32.6;
 text(lon(1,1)+0.1,l1+0.1, 'B','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');
 text(lon(1,end)-0.1,l1+0.1, 'B''','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');
end

lsec =  find(lat(:,:) > l1,1);

% plot line section
 x1 = [lon(1,1) lon(1,end)];
 y1 = [lat(lsec,1) lat(lsec,1)];

 line(x1,y1,'LineStyle','-','Color','k','LineWidth',1.5);


% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);

 title('\sigma','FontSize',18)
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/Rho_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/Rho_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % depth
end % end day
end % end arch

end % end region
