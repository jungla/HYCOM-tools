clear; close all;
%%%% dimensions  
gridbfid=fopen('../../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);


for time = 1:1

day   = textread('../../archivesDay_fl');
year  = textread('../../archivesYear_fl');

[X1,X2,Y1,Y2,R] = regions_fl(1,time)
[x1,x2,y1,y2,R] = regions_fl_box(time)

ids = X2-X1;
jds = Y2-Y1; 
ijds = ids*jds;

lon = tlon(1,X1+1:X2-1);
lat = tlat(Y1:Y2-1,1);

slon = lon(1,x1:x2-1);
slat = lat(y1:y2-1,1);

depth = 1;
hd = '00'

for t = 0:5
for hd = 0:12:12

hd     = digit(hd,2)
lday   = digit(day(time)+t,3)
lyear  = digit(year(time),4)

file1 = strcat('../../../../GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_',hd,'_2m_FL_3zt.A');
file2 = strcat('../../../../GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_',hd,'_2m_FL_3zs.A');
file3 = strcat('../../../../GSa0.02_2m_1k_FL/016_archv.',lyear,'_',lday,'_',hd,'_2m_FL_3zr.A');

T = binaryread(file1,ids,jds,ijds,depth);
S = binaryread(file2,ids,jds,ijds,depth);
R = binaryread(file3,ids,jds,ijds,depth);

T = T(:,2:end);
S = S(:,2:end);
R = R(:,2:end);

%T = smooth2(T,1);
%S = smooth2(S,1);

Ts = T(y1:y2-1,x1:x2-1);
Ss = S(y1:y2-1,x1:x2-1);
Rs = R(y1:y2-1,x1:x2-1);

%smooth2(Ts,1);
%smooth2(Ss,1);

'plotting...'


%%%%%%%%%% T

 Tmax = quantile(T(~isnan(T)),0.95)
 Tmin = quantile(T(~isnan(T)),0.05)

 ch = figure();
 imagesc(lon,lat,T);
 %set(ch,'edgecolor','none');
 %load('OWColorMap.mat','mycmap')
 %set(ch,'Colormap',mycmap)
 colorbar
 caxis([Tmin Tmax])
 axis image;
 axis xy;

 title('T','FontSize',24)
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image


 label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_FL_T.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;

%%%%%%%%%% Ts

 if time == 2
 Tmax = 21.0;%quantile(Ts(~isnan(Ts)),0.95)
 Tmin = 19.8;%quantile(Ts(~isnan(Ts)),0.05)
 else
 Tmax = quantile(Ts(~isnan(Ts)),0.95)
 Tmin = quantile(Ts(~isnan(Ts)),0.05)
 end

 ch = figure();
 imagesc(slon,slat,Ts);
 %set(ch,'edgecolor','none');
 %load('OWColorMap.mat','mycmap')
 %set(ch,'Colormap',mycmap)
 colorbar
 caxis([Tmin Tmax])
 axis image;
 axis xy;

 title(strcat('T,',lday,' ',hd),'FontSize',24)
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image


 label = strcat('./plot/front_box_h_016_archv.',lyear,'_',lday,'_',hd,'_FL_T.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;

%%%%%%%%%% S

 Smax = quantile(S(~isnan(S)),0.95)
 Smin = quantile(S(~isnan(S)),0.05)

 ch = figure();
 imagesc(lon,lat,S);
 %set(ch,'edgecolor','none');
 %load('OWColorMap.mat','mycmap')
 %set(ch,'Colormap',mycmap)
 colorbar
 caxis([Smin Smax])
 axis image;
 axis xy;

 title('S','FontSize',24)
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image


 label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_FL_S.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;

%%%%%%%%%% Ss

 Smax = quantile(Ss(~isnan(Ss)),0.95)
 Smin = quantile(Ss(~isnan(Ss)),0.05)

 ch = figure();
 imagesc(slon,slat,Ss);
 %set(ch,'edgecolor','none');
 %load('OWColorMap.mat','mycmap')
 %set(ch,'Colormap',mycmap)
 colorbar
 caxis([Smin Smax])
 axis image;
 axis xy;

 title('S','FontSize',24)
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image


 label = strcat('./plot/front_box_h_016_archv.',lyear,'_',lday,'_',hd,'_FL_S.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;

%%%%%%%%%% R

 Rmax = quantile(R(~isnan(R)),0.95)
 Rmin = quantile(R(~isnan(R)),0.05)

 ch = figure();
 imagesc(lon,lat,R);
 %set(ch,'edgecolor','none');
 %load('OWColorMap.mat','mycmap')
 %set(ch,'Colormap',mycmap)
 colorbar
 caxis([Rmin Rmax])
 axis image;
 axis xy;

 title('\sigma','FontSize',24)
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image


 label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_FL_R.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;

%%%%%%%%%% Rs

 Rmax = quantile(Rs(~isnan(Rs)),0.95)
 Rmin = quantile(Rs(~isnan(Rs)),0.05)

 ch = figure();
 imagesc(slon,slat,Rs);
 %set(ch,'edgecolor','none');
 %load('OWColorMap.mat','mycmap')
 %set(ch,'Colormap',mycmap)
 colorbar
 caxis([Rmin Rmax])
 axis image;
 axis xy;

 title('\sigma','FontSize',24)
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image


 label = strcat('./plot/front_box_h_016_archv.',lyear,'_',lday,'_',hd,'_FL_R.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;


end
end
end
