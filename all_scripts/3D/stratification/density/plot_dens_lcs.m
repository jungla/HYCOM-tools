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

for time  = 1:2

for arch = 1:2

if arch == 1
 day   = textread('../../../3D/archivesDay_2_h_lcs');
 year  = textread('../../../3D/archivesYear_2_h_lcs');
else
 day   = textread('../../../3D/archivesDay_2_l_lcs');
 year  = textread('../../../3D/archivesYear_2_l_lcs');
end

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for region = 1:2:5

[X1,X2,Y1,Y2,R,lsec,buoys] = regions_lcs(region+time,arch);

lon = tlon(1,X1:X2-1);
lat = tlat(Y1:Y2-1,1);

ids = X2-X1;
jds = Y2-Y1;
ijds = ids*jds;

for did = 1:2

 depth = readline('../../../3D/layersDepth_2_lcs',did);
 depthid = str2num(readline('../../../3D/layersDepthID_2_lcs',did));

if arch == 1
 file1  = strcat('../../../../GSa0.0x_2m_1k/016_archv.',lyear,'_',lday,'_00_2m_',R,'_3zr.A');
else
 file1  = strcat('../../../../GSa0.0x_2m_1k/archv.',lyear,'_',lday,'_00_2m_',R,'_3zr.A');
end

Rhot = binaryread(file1,ids,jds,ijds,depthid);

Rho = Rhot(:,:);
Rho(Rho < 1) = NaN;

 [ch] = figure();
% orient landscape;

%%%%%%%%%%%%%%%%%%%%%% plot w

maxR = quantile(Rho(~isnan(Rho)),0.95)
minR = quantile(Rho(~isnan(Rho)),0.05)

% [p1,p1] = contourf(lon,lat,w);
 p1 = imagesc(lon,lat,Rho);
 hold on
 axis xy;
 caxis([minR maxR])
% caxis([-2.5*10^-4 2.5*10^-4])
% set(p1,'LineStyle','none');

%% plot line section
% x1 = [lon(1,1) lon(1,end)];
% y1 = [lat(lsec,1) lat(lsec,1)];
% line(x1,y1,'LineStyle','-','Color','k','LineWidth',1.5);

% plot(lon(1,buoys(1)),lat(lsec,1),'Marker','o','Color','k','MarkerFaceColor','k')
% text(lon(1,buoys(1)),lat(lsec,1)+0.2, 'A','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');

% plot(lon(1,buoys(2)),lat(lsec,1),'Marker','o','Color','k','MarkerFaceColor','k')
% text(lon(1,buoys(2)),lat(lsec,1)+0.2, 'B','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');

% plot(lon(1,buoys(3)),lat(lsec,1),'Marker','o','Color','k','MarkerFaceColor','k')
% text(lon(1,buoys(3)),lat(lsec,1)+0.2, 'C','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');

 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)
 axis image

if arch == 1
 title('\rho, HR','FontSize',21);
 label = strcat('./plot/high-res/Rho_',depth,'_',lyear,'_',lday,'_h_',R,'_lcs.eps')
else
 title('\rho, LR','FontSize',21);
 label = strcat('./plot/low-res/Rho_',depth,'_',lyear,'_',lday,'_l_',R,'_lcs.eps')
end
 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % arch
end % depth
end % end day

end % end region
