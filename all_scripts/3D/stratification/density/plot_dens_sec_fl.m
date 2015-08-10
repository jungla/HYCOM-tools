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



R = 'FL'
X1 = 1200
X2 = 1500
Y1 = 170
Y2 = 470

for time = 1:2

if time == 1
 dmax = 70;  % depth (m)
 N = 36;      % total number of layers, don't touch this. just change the displayed depth
 day  = 291;
 year = 8;
else
 dmax = 400;  % depth (m)
 N = 201;      % total number of layers, don't touch this. just change the displayed depth
 day  = 31;
 year = 9;
end

 depths = textread('../../layersDepth_lcs');
 depths = depths(1:N);
 depth = 1;
 hd = '00';

if year == 8
 x1t = 1270;
 x2t = 1300;
 y1t = 370;
 y2t = 410;
else
 x1t = 1300;
 x2t = 1330;
 y1t = 265;
 y2t = 320;
end

x1 = x1t - X1
x2 = x1 + (x2t - x1t)
y1 = y1t - Y1
y2 = y1 + (y2t - y1t)

lat = tlat(Y1:Y2-1,1);
lon = tlon(1,X1:X2-1);

slon = lon(1,x1:x2-1);
slat = lat(y1:y2-1,1);

% section passing in the middle of the box

l1id = floor(x1+(x2-x1)/2)

lday   = digit(day,3)
lyear  = digit(year,4)

 file0 = strcat('/tamay/mensa/hycom/GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_00_2m_',R,'_3zt.A');
 file1 = strcat('/tamay/mensa/hycom/GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_00_2m_',R,'_3zs.A');
 file2 = strcat('/tamay/mensa/hycom/GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_00_2m_',R,'_3zr.A');

 ids = X2-X1;
 jds = Y2-Y1;
 ijds = ids*jds;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T = nan(ids,jds,N);
S = nan(ids,jds,N);
Rho = nan(ids,jds,N);

for k = 1:N
 T(:,:,k) = binaryread(file0,ids,jds,ijds,k);
 S(:,:,k) = binaryread(file1,ids,jds,ijds,k);
 Rho(:,:,k) = binaryread(file2,ids,jds,ijds,k);
end

clear sectionT sectionS sectionR

sectionT(:,:) = T(y1:y2-1,l1id,:);
sectionT = sectionT';

sectionS(:,:) = S(y1:y2-1,l1id,:);
sectionS = sectionS';

sectionR(:,:) = Rho(y1:y2-1,l1id,:);
sectionR = sectionR';

%%%%%%%%%%%%%%%%%%%%%%%%%%% S
 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(slat,depths,sectionS,50);
 set(p1,'edgecolor','none');
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')


 title('S','FontSize',24)
 ylabel('Depth (m)','FontSize',21);
 xlabel('Longitude','FontSize',21);
 set(gca,'FontSize',18)

 cb = colorbar;
 set(cb, 'FontSize',18)
% axis image
 axis ij;
 hold off;

if time == 1
% caxis([36.32 36.42]);
else
 caxis([36.32 36.42]);
end

 ylim([0 dmax]);

 label = strcat('./plot/S_sec_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'.eps')

 print(ch,'-dpsc2',label);

close all;

%%%%%%%%%%%%%%%%%%% T
ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(slat,depths,sectionT,50);
 set(p1,'edgecolor','none');
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')
 title('T','FontSize',24)
 ylabel('Depth (m)','FontSize',21);
 xlabel('Longitude','FontSize',21);
 set(gca,'FontSize',18)

 cb = colorbar;
 set(cb, 'FontSize',18)
% axis image
 axis ij;
 hold off;

if time == 1
% caxis([19 20.5]);
else
 caxis([19 20.5]);
end

 ylim([0 dmax]);

 label = strcat('./plot/T_sec_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'.eps')

 print(ch,'-dpsc2',label);

close all;


%%%%%%%%%%%%%%%%%%% R
ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(slat,depths,sectionR,50);
 set(p1,'edgecolor','none');
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')
 title('\sigma','FontSize',24)
 ylabel('Depth (m)','FontSize',21);
 xlabel('Longitude','FontSize',21);
 set(gca,'FontSize',18)

 cb = colorbar;
 set(cb, 'FontSize',18)
% axis image
 axis ij;
 hold off;

% caxis([19 20.5]);
 ylim([0 dmax]);

 label = strcat('./plot/R_sec_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'.eps')

 print(ch,'-dpsc2',label);

close all;

end % time loop
