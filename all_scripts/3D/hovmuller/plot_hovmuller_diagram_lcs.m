clear all;

gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line1 = fgetl(gridbfid);
idm  = sscanf(line1,'%f',1);
line1 = fgetl(gridbfid);
jdm  = sscanf(line1,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region

ijdm = idm*jdm;

file = '../../topo0.02/regional.grid.a';
filet = '../../topo0.02/depth_GSa0.02_08.a';

ttopo = hycomread(filet,idm,jdm,ijdm,1);

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

dmax = 1000;  % depth (m)

N = 501;      % total number of layers, don't touch this. just change the displayed depth

depths = textread('../layersDepth_lcs');

for arch = 1:2

if arch == 1
 day   = textread('../../3D/archivesDay_22_h_lcs');
 year  = textread('../../3D/archivesYear_22_h_lcs');
else
 day   = textread('../../3D/archivesDay_22_l_lcs');
 year  = textread('../../3D/archivesYear_22_l_lcs');
end

for season = 1:2

for region = 1:2:5

[X1,X2,Y1,Y2,R,lsec,buoys] = regions_lcs(region+season,arch);

lat = tlat(Y1:Y2-1,1);
lon = tlon(1,X1:X2-1);

for buoyid  = 1:3

timeid = 0

clear sectionW sectionU sectionV

for time  = 1:11

lday  = digit(day(time+(season-1)*11),3);
lyear = digit(year(time+(season-1)*11),4);

lday
lyear

for hdid = 1:2

if arch == 2 & hdid == 2
 break
end

if hdid == 1
 hd = '00'
else
 hd = '12'
end 

timeid = timeid + 1
timeBar(timeid) = day(time);

clear depth 

if arch == 1
 file  = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/016_archv.',lyear,'_',lday,'_',hd,'_2m_',R,'_3zw.A');
 file0 = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/016_archv.',lyear,'_',lday,'_',hd,'_2m_',R,'_3zu.A');
 file1 = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/016_archv.',lyear,'_',lday,'_',hd,'_2m_',R,'_3zv.A');
else
 file  = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/archv.',lyear,'_',lday,'_',hd,'_2m_',R,'_3zw.A');
 file0 = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/archv.',lyear,'_',lday,'_',hd,'_2m_',R,'_3zu.A');
 file1 = strcat('/tamay/mensa/hycom/GSa0.0x_2m_1k/archv.',lyear,'_',lday,'_',hd,'_2m_',R,'_3zv.A');
end

 ids = X2-X1;
 jds = Y2-Y1;
 ijds = ids*jds;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove nan and reshape matrix    %

w = nan(ids,jds,N);
u = nan(ids,jds,N);
v = nan(ids,jds,N);

for k = 1:N
 w(:,:,k) = binaryread(file,ids,jds,ijds,k);
 u(:,:,k) = binaryread(file0,ids,jds,ijds,k);
 v(:,:,k) = binaryread(file1,ids,jds,ijds,k);
end

sectionW(:,timeid) = w(buoys(buoyid),lsec,:);
sectionU(:,timeid) = u(buoys(buoyid),lsec,:);
sectionV(:,timeid) = v(buoys(buoyid),lsec,:);

end % end hd
end % end time

%%%%%%%%%%%%
% plotting %

if buoyid == 1
 lb = 'A'
elseif buoyid == 2
 lb = 'B'
else
 lb = 'C'
end

%%%%%%%%%%%%%%%%%% ANOMALIES


%%%%%%%%%%%%%%%%%%% Wa

 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(1:timeid,depths,sectionW - nanmean(nanmean(sectionW)),50);
 set(p1,'edgecolor','none');
 %caxis([-2e-3 2e-3]);
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')

 ylabel('Depth (m)','FontSize',21);
 xlabel('time','FontSize',21);

 set(gca,'XTick', 1:2:timeid);
 set(gca,'XTickLabel',timeBar(1:2:end))
 set(gca,'FontSize',18)

 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)


 title(strcat(['Hovmuller diagram for W buoy ',lb]),'FontSize',24)

 cb = colorbar;
 set(cb, 'FontSize',18)
% axis image
 axis ij;
 hold off;

% caxis([rmin rmax]);
% ylim([0 dmax]);

if arch == 1
 label = strcat('./plot/hovmuller_wa_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'_b',num2str(buoyid),'_lcs.eps')
else
 label = strcat('./plot/hovmuller_wa_',num2str(dmax),'m_',lyear,'_',lday,'_l_',R,'_b',num2str(buoyid),'_lcs.eps')
end

 print(ch,'-dpsc2',label);

%%%%%%%%%%%%%%%%%%% Ua

 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(1:timeid,depths,sectionU - nanmean(nanmean(sectionU)),50);
 set(p1,'edgecolor','none');
 %caxis([-2e-3 2e-3]);
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')

 ylabel('Depth (m)','FontSize',18);
 xlabel('time','FontSize',18);

 set(gca,'XTick', 1:2:timeid);
 set(gca,'XTickLabel',timeBar(1:2:end))
 set(gca,'FontSize',16)

 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)

 title(strcat(['Hovmuller diagram for U buoy ',lb]),'FontSize',24)

 cb = colorbar;
 set(cb, 'FontSize',16)
% axis image
 axis ij;
 hold off;

% caxis([rmin rmax]);
% ylim([0 dmax]);

if arch == 1
 label = strcat('./plot/hovmuller_ua_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'_b',num2str(buoyid),'_lcs.eps')
else
 label = strcat('./plot/hovmuller_ua_',num2str(dmax),'m_',lyear,'_',lday,'_l_',R,'_b',num2str(buoyid),'_lcs.eps')
end

 print(ch,'-dpsc2',label);


%%%%%%%%%%%%%%%%%%% Va

 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(1:timeid,depths,sectionV - nanmean(nanmean(sectionV)),50);
 set(p1,'edgecolor','none');
 %caxis([-2e-3 2e-3]);
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')

 ylabel('Depth (m)','FontSize',21);
 xlabel('time','FontSize',21);

 set(gca,'XTick', 1:2:timeid);
 set(gca,'XTickLabel',timeBar(1:2:end))
 set(gca,'FontSize',18)

 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)

 title(strcat(['Hovmuller diagram for V buoy ',lb]),'FontSize',24)

 cb = colorbar;
 set(cb, 'FontSize',16)
% axis image
 axis ij;
 hold off;

% caxis([rmin rmax]);
% ylim([0 dmax]);

if arch == 1
 label = strcat('./plot/hovmuller_va_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'_b',num2str(buoyid),'_lcs.eps')
else
 label = strcat('./plot/hovmuller_va_',num2str(dmax),'m_',lyear,'_',lday,'_l_',R,'_b',num2str(buoyid),'_lcs.eps')
end

 print(ch,'-dpsc2',label);

close all;


%%%%%%%%%%%%%%%%%%% Not Anomalies

%%%%%%%%%%%%%%%%%%% W

 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(1:timeid,depths,sectionW,50);
 set(p1,'edgecolor','none');
 %caxis([-2e-3 2e-3]);
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')

 ylabel('Depth (m)','FontSize',21);
 xlabel('time','FontSize',21);

 set(gca,'XTick', 1:2:timeid);
 set(gca,'XTickLabel',timeBar(1:2:end))
 set(gca,'FontSize',18)

 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)


 title(strcat(['Hovmuller diagram for W buoy ',lb]),'FontSize',24)

 cb = colorbar;
 set(cb, 'FontSize',18)
% axis image
 axis ij;
 hold off;

% caxis([rmin rmax]);
% ylim([0 dmax]);

if arch == 1
 label = strcat('./plot/hovmuller_w_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'_b',num2str(buoyid),'_lcs.eps')
else
 label = strcat('./plot/hovmuller_w_',num2str(dmax),'m_',lyear,'_',lday,'_l_',R,'_b',num2str(buoyid),'_lcs.eps')
end

 print(ch,'-dpsc2',label);

%%%%%%%%%%%%%%%%%%% U

 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(1:timeid,depths,sectionU,50);
 set(p1,'edgecolor','none');
 %caxis([-2e-3 2e-3]);
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')

 ylabel('Depth (m)','FontSize',18);
 xlabel('time','FontSize',18);

 set(gca,'XTick', 1:2:timeid);
 set(gca,'XTickLabel',timeBar(1:2:end))
 set(gca,'FontSize',16)

 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)

 title(strcat(['Hovmuller diagram for U buoy ',lb]),'FontSize',24)

 cb = colorbar;
 set(cb, 'FontSize',16)
% axis image
 axis ij;
 hold off;

% caxis([rmin rmax]);
% ylim([0 dmax]);

if arch == 1
 label = strcat('./plot/hovmuller_u_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'_b',num2str(buoyid),'_lcs.eps')
else
 label = strcat('./plot/hovmuller_u_',num2str(dmax),'m_',lyear,'_',lday,'_l_',R,'_b',num2str(buoyid),'_lcs.eps')
end

 print(ch,'-dpsc2',label);


%%%%%%%%%%%%%%%%%%% V

 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(1:timeid,depths,sectionV,50);
 set(p1,'edgecolor','none');
 %caxis([-2e-3 2e-3]);
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')

 ylabel('Depth (m)','FontSize',21);
 xlabel('time','FontSize',21);

 set(gca,'XTick', 1:2:timeid);
 set(gca,'XTickLabel',timeBar(1:2:end))
 set(gca,'FontSize',18)

 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)

 title(strcat(['Hovmuller diagram for V buoy ',lb]),'FontSize',24)

 cb = colorbar;
 set(cb, 'FontSize',16)
% axis image
 axis ij;
 hold off;

% caxis([rmin rmax]);
% ylim([0 dmax]);

if arch == 1
 label = strcat('./plot/hovmuller_v_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'_b',num2str(buoyid),'_lcs.eps')
else
 label = strcat('./plot/hovmuller_v_',num2str(dmax),'m_',lyear,'_',lday,'_l_',R,'_b',num2str(buoyid),'_lcs.eps')
end

 print(ch,'-dpsc2',label);




close all;

end % end section
end % end day
end % end section
end % end section
