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

dmax = 500;  % depth (m)
step = 4000;  % mesh # points

N = 41;      % total number of layers, don't touch this. just change the displayed depth

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

lat = tlat(Y1:Y2,1);
lon = tlon(1,X1:X2);
pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;

vmin = 0
vmax = 0.3

%ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');
ch = figure() %'PaperPosition', [0 0 1 1],'PaperUnits','normalized');

for arch = 1:1

for time  = 2:2

day   = textread('../archivesDay_2');
year  = textread('../archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

arch

lday
lyear

%%%%%%%%%%%%%%%%  read Vort %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%B = zeros(41,jds,ids);

for did = 1:41

depth(did) = str2num(readline('../layersDepth_all_02',did));

if (arch == 1)
% filer = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/high-res/filter_02_h_070_archv.',lyear,'_',lday,'_00_r.a');
 filero = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zr.A');
else
% filer = strcat('/tamay/mensa/hycom/scripts/3D/filter_paral/output/low-res/filter_02_l_070_archv.',lyear,'_',lday,'_00_r.a');
 filero = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zr.A');
end

ftro = -(binaryread(filero,idm,jdm,ijdm,did)+1000)*9.81./1000;

fro  = ftro(Y1:Y2,X1:X2);

%%%%%%%%%%%%%%%%%%%%%% filter B

B(did) = avg_region(fro,pscx,pscy,1,ids,1,jds,0);

end

%for did = 1:40
%N2(did) = avg_region(squeeze(B(did,:,:)-B(did+1,:,:)),pscx,pscy,1,ids,1,jds,0);
%end
%N2(41) = avg_region(squeeze(B(41,:,:)-B(40,:,:)),pscx,pscy,1,ids,1,jds,0);

N2 = gradient(B)./gradient(-depth)

%%%%%%%%%%%%%%%%  read mld %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if (arch == 1)
  file1 = strcat('../../stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.',lyear,'_',lday,'_00.a');
 else
  file1 = strcat('../../stratification/mixedlayer/output/low-res/mixlayer_l_016_archv.',lyear,'_',lday,'_00.a');
 end

 tml = binaryread(file1,idm,jdm,ijdm,1);
 ml = tml(Y1:Y2,X1:X2);
 ml = ml./9806;

 mld = avg_region(ml,pscx,pscy,1,ids,1,jds,0);

%%%%%%%%%%%%%%%%%%%%%%%
% INTERPOLATIONS      %

 minY = 0.0; %min(section(1:fd,2));
 maxY = 4000; %max(section(1:fd,2));

 YI = minY:(maxY-minY)/step:maxY;

 ZIr = interp1(depth(:),N2,YI,'cubic');


% vmin = min(vmin,min(V));
% vmax = max(vmax,max(V));

%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%if arch == 1
 p1 = plot(ZIr,'LineWidth',2,'LineStyle','-');
 set(p1,'Color','k');
%end
% hold on;
% p1 = plot(ZIf,'LineWidth',2,'LineStyle','--');

 view(-90,90)

if arch == 1
% plot(mld,ZIr(find(YI>mld,1)),'ro','MarkerSize',12,'MarkerFaceColor','r');
 'mld:',mld
else
% plot(mld,ZIr(find(YI>mld,1)),'ro','MarkerSize',12,'MarkerFaceColor','b');
 'mld:',mld
end
% plot(mld,ZIf(find(YI>mld,1)),'ro','MarkerSize',7,'MarkerFaceColor','r');

 xlabel('Depth (m)','FontSize',21);
% ylabel('<|\nabla \bar{b}|>_{xy}','FontSize',21);
 ylabel('<N^2>_{xy}','FontSize',21);
 set(gca,'FontSize',21)
 set(gca,'XDir','reverse');
 set(gca,'YDir','reverse');

% title({'\rho';tlabel},'FontSize',21)

 xlim([0 dmax]);
% ylim([-1*10^-8 5*10^-8]);

end % end day
end % end arch

 label = strcat('./plot/N2_z_',num2str(dmax),'_',R,'.eps')

 print(ch,'-dpsc2',label);

close all;

end % end region
