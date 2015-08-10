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

%vmin = 33.7; % good values for 1m: 33.5 37.0
%vmax = 34.7; % values for ml:         33.0 35.0

dmax = 2000;  % depth (m)
step = 4000;  % mesh # points

N = 30;      % total number of layers, don't touch this. just change the displayed depth

for region = 1:1

[X1,X2,Y1,Y2,R] = regions(region);

lat = tlat(Y1:Y2,1);
lon = tlon(1,X1:X2);

vmin = 0
vmax = 0.15

ch = figure();

for arch = 1:2

for time  = 1:2

day   = textread('../archivesDay_2');
year  = textread('../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

arch

lday
lyear

%%%%%%%%%%%%%%%%  read Vort %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for did = 1:22

depth(did) = str2num(readline('../layersDepth',did));

 if (arch == 1)
  file = strcat('./output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_00.a');
 else
  file = strcat('./output/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_00.a');
 end

 tvort = binaryread(file,idm,jdm,ijdm,did);
 tvort = abs(tvort);
 tvort = tvort./(8*10^-5);
 V(did) = length(tvort(tvort > 0.5))/length(tvort(~isnan(tvort))); 
end

%%%%%%%%%%%%%%%%  read mld %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if (arch == 1)
  file1 = strcat('../../stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.',lyear,'_',lday,'_00.a');
 else
  file1 = strcat('../../stratification/mixedlayer/output/low-res/mixlayer_l_016_archv.',lyear,'_',lday,'_00.a');
 end

 tml = binaryread(file1,idm,jdm,ijdm,1);
 tml = tml./9806;

 mld = avg_region(tml,tpscx,tpscy,X1,X2,Y1,Y2,0);

%%%%%%%%%%%%%%%%%%%%%%%
% INTERPOLATIONS      %

 minY = 0.0; %min(section(1:fd,2));
 maxY = 4000; %max(section(1:fd,2));

 YI = minY:(maxY-minY)/step:maxY;

 ZI = interp1(depth(:),V(:),YI,'cubic');

% vmin = min(vmin,min(V));
% vmax = max(vmax,max(V));

%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

 p1 = plot(ZI,'LineWidth',2);

 hold on;

if arch == 1
 set(p1,'Color','k');
else
 set(p1,'Color','b');
end

if time == 1
 set(p1,'LineStyle','--');
else
 set(p1,'LineStyle','-');
end


 view(-90,90)

 plot(mld,ZI(find(YI>mld,1)),'ro','MarkerSize',7,'MarkerFaceColor','r');

 xlabel('Depth (m)','FontSize',21);
 ylabel('<count(|Ro|>0.5)>','FontSize',21);
 set(gca,'FontSize',21)
 set(gca,'XDir','reverse');
 set(gca,'YDir','reverse');

% title({'\rho';tlabel},'FontSize',21)

 xlim([0 dmax]);
 ylim([vmin vmax]);

end % end day
end % end arch

 label = strcat('./plot/vort_f_z_',num2str(dmax),'_',R,'.eps')

 print(ch,'-dpsc2',label);

close all;

end % end region
