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

dmax = 400;  % depth (m)

N = 22;      % total number of layers, don't touch this. just change the displayed depth

depths = textread('../layersDepth');

for time  = 1:2

day   = textread('../../archivesDay_2');
year  = textread('../../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for region = 1:1

[X1,X2,Y1,Y2,R] = regions(region);

l1 = 31.75;

lsec =  find(lat(:,:) > l1,1);


lat = tlat(Y1:Y2-1,1);
lon = tlon(1,X1:X2-1);


for sectid  = 1:2

%%%%%% 2 sections per map in the middle
 if sectid ==1
  l1id = lsec;
 else
  l1id = lsec;
 end

for s = 1:1 % type of section

clear depth section sectionR

 file0 = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
 file1 = strcat('../../stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.',lyear,'_',lday,'_00.a');

 ids = X2-X1;
 jds = Y2-Y1;
 ijds = ids*jds;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove nan and reshape matrix    %

Rho = nan(ids,jds,N);

for k = 1:N
 Rho(:,:,k) = binaryread(file0,ids,jds,ijds,k);
end

sectionR(:,:) = Rho(l1id,:,:);
sectionR = sectionR';

% section(isnan(section(:,3)),2) = NaN;

% section(isnan(section(:,3)),:) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute ML, for each day, for each resolution %

 tml = hycomread(file1,idm,jdm,ijdm,1);
 tml = tml./9806;

if(s == 1)
  mld = tml(l1id,X1:X2-1);
else
  mld = tml(Y1:Y2,l1id);
end

 %mld = avg_region(tml,tpscx,tpscy,X1,X2,Y1,Y2,s);

%%%%%%%%%%%%
% plotting %

 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

 wmax = max(max(section));
 wmin = min(min(section));

 Wmax = max(abs(wmax),abs(wmin));

%%%%%%%%%%%%%%%%%%%%%%%%%%%

% p1 = imagesc(lon,YI,ZI);
 [p1,p1] = contourf(lon,depths,section,50);
 set(p1,'edgecolor','none');
% caxis([-Wmax Wmax]);
 caxis([33.2 34.5]);
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')
 plot(lon,mld,'Color','white','LineWidth',2);

 [p2,p2] = contour(lon,depths,sectionR,'Color',[0 0 0]);
 set(p2,'ShowText','on','TextStep',get(p2,'LevelStep')*4,'LineWidth',1);
 th = clabel(p2,p2,'Color',[0 0 0],'FontSize',12,'LabelSpacing',92);

 ylabel('Depth (m)','FontSize',18);
 xlabel('Longitude','FontSize',18);
 set(gca,'FontSize',16)

 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)


 cb = colorbar;
 set(cb, 'FontSize',16)
% axis image
 axis ij;
 hold off;

% caxis([rmin rmax]);
% ylim([0 dmax]);


 label = strcat('./plot/high-res/dens_sec_',num2str(dmax),'m_',lyear,'_',lday,'_h_',R,'_s',num2str(s),'.eps')


 print(ch,'-dpsc2',label);

close all;

end % end section
end % end day
end % end section
end % end region
