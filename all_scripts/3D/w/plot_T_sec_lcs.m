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

rmin = 33.0; % good values for 1m: 33.5 37.0
rmax = 35.0; % values for ml:         33.0 35.0

dmax = 500;  % depth (m)

N = 501;      % total number of layers, don't touch this. just change the displayed depth

depths = textread('../layersDepth_all_l01');

for arch = 1:1

for time  = 2:2

if arch == 1
 day   = textread('../../3D/archivesDay_2_h_l01');
 year  = textread('../../3D/archivesYear_2_h_l01');
else
 day   = textread('../../3D/archivesDay_2_l_l01');
 year  = textread('../../3D/archivesYear_2_l_l01');
end

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for region = 1:3 %1:2:5

[X1,X2,Y1,Y2,R,lsec] = regions_lcs(region,time,arch);

lat = tlat(Y1:Y2-1,1);
lon = tlon(1,X1:X2-1);


for sectid  = 1:1

%%%%%% 2 sections per map in the middle
 if sectid ==1
  l1id = X1+(X2-X1)/2;
 else
  l1id = Y1+(Y2-Y1)/2;
 end


clear depth section sectionR

if arch == 1
 file0 = strcat('/tamay/mensa/hycom/GSa0.0x_l01/l01_h_archv.',lyear,'_',lday,'_00_',R,'_3zt.a');
 file1 = strcat('../../stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file0 = strcat('/tamay/mensa/hycom/GSa0.0x_l01/l01_l_archv.',lyear,'_',lday,'_00_',R,'_3zt.a');
 file1 = strcat('../../stratification/mixedlayer/output/low-res/mixlayer_l_016_archv.',lyear,'_',lday,'_00.a');
end

 ids = X2-X1;
 jds = Y2-Y1;
 ijds = ids*jds;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove nan and reshape matrix    %

T = nan(ids,jds,N);

for k = 1:N
 T(:,:,k) = binaryread(file0,ids,jds,ijds,k);
end

if(sectid == 1)
 sectionR(:,:) = T(:,(X2-X1)/2,:);
else
 sectionR(:,:) = T((Y2-Y1)/2,:,:);
end


sectionR = sectionR';

% section(isnan(section(:,3)),2) = NaN;

% section(isnan(section(:,3)),:) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute ML, for each day, for each resolution %

 tml = hycomread(file1,idm,jdm,ijdm,1);
 tml = tml./9806;

if(sectid == 1)
  mld = tml(Y1:Y2-1,l1id);
else
  mld = tml(l1id,X1:X2-1);
end

 %mld = avg_region(tml,tpscx,tpscy,X1,X2,Y1,Y2,s);

%%%%%%%%%%%%
% plotting %

 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

%%%%%%%%%%%%%%%%%%%%%%%%%%%

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(lon,depths,sectionR,50);
 set(p1,'edgecolor','none');
% caxis([-Wmax Wmax]);
% caxis([-2e-3 2e-3]);
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')
 plot(lon,mld,'Color','white','LineWidth',2);

 ylabel('Depth (m)','FontSize',21);
 xlabel('Longitude','FontSize',21);
 set(gca,'FontSize',21)



 cb = colorbar;
 set(cb, 'FontSize',21)
% axis image
 axis ij;
 hold off;

% caxis([rmin rmax]);
% ylim([0 dmax]);

if arch == 1
 title([R,',',lday,', HR'],'FontSize',21);
 label = strcat('./plot/high-res/T_sec_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'_s',num2str(sectid),'_lcs.eps')
else
 title([R,',',lday,', LR'],'FontSize',21);
 label = strcat('./plot/low-res/T_sec_',num2str(dmax),'m_',lyear,'_',lday,'_l_',R,'_s',num2str(sectid),'_lcs.eps')
end

 print(ch,'-dpsc2',label);

close all;

end % end section
end % end section
end % end day
end % end section
