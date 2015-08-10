clear; close all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

X1 = 1300;
X2 = 1330;
Y1 = 265;
Y2 = 320;

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;

%x1 = X1 - 472
%x2 = x1 + (X1- 472)
%y1 = Y1 - 80
%y2 = y1 + (Y1 - 80)

omega  = 7.2921150*10^-5;
f(:,:) = zeros(jdm,idm);
f(:,:) = 2*omega*sin(tlat(:,:)*pi/90);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

%lat = flipdim(lat,2);

day  = 30;
year = 9;
depth = 1;
hd = '00'

for timeid = 1:1
day = day + 1;

for t = 1:1

lday   = digit(day,3)
lyear  = digit(year,4)
ldepth = digit(depth,4)

file  = strcat('../stratification/Ri/output/high-res/ri_h_016_archv.',lyear,'_',lday,'_',hd,'.a');
file1 = strcat('./output/high-res/vorticity_a_h_016_archv.',lyear,'_',lday,'_',hd,'.a');
file2 = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_',hd,'_3zw.A');
%file3   = strcat('../qvector/output/high-res/F_h_016_archv.',lyear,'_',lday,'_00.a');
file4   = strcat('../omega/output/high-res/O_front_a_h_',lyear,'_',lday,'_00.a');

%Rit  = binaryread(file,idm,jdm,ijdm,4);
Vort = hycomread(file1,idm,jdm,ijdm,depth);
%wt   = binaryread(file2,idm,jdm,ijdm,4);
%Ft   = binaryread(file3,idm,jdm,ijdm,4);
%Ot   = binaryread(file4,ids,jds,ijds,16);

Rot   = Vort./f;

%w  = wt(Y1:Y2,X1:X2);
Ro = Rot(Y1:Y2,X1:X2);
%Ri = Rit(Y1:Y2,X1:X2);
%F  = Ft(Y1:Y2,X1:X2);
%O  = Ot(:,:);

'plotting...'


%%%%%%%%%% Ro
 ch = figure();
 imagesc(lon,lat,Ro);
 %set(ch,'edgecolor','none');
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
 colorbar
 caxis([-1 1])
 axis image;
 axis xy;

if(timeid == 1 || timeid == 3)
 title('Ro','FontSize',24)
end
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image


 label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_fl_Ro.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;


end
end
