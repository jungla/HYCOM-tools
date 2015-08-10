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

Y1 = 158;
Y2 = 216;
X1 = 1062;
X2 = 1122;

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

day  = 309;
year = 8;
depth = 30;
hd = '12'

for timeid = 1:4
day = day + 1;

for t = 1:1

lday   = digit(day,3)
lyear  = digit(year,4)
ldepth = digit(depth,4)

file  = strcat('../stratification/Ri/output/high-res/ri_h_016_archv.',lyear,'_',lday,'_',hd,'.a');
file1 = strcat('./output/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_',ldepth,'_',hd,'.a');
file2 = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_',hd,'_3zw.A');
%file3   = strcat('../qvector/output/high-res/F_h_016_archv.',lyear,'_',lday,'_00.a');
file4   = strcat('../omega/output/high-res/O_front_a_h_',lyear,'_',lday,'_00.a');

Rit  = binaryread(file,idm,jdm,ijdm,4);
Vort = hycomread(file1,idm,jdm,ijdm,1);
wt   = binaryread(file2,idm,jdm,ijdm,4);
%Ft   = binaryread(file3,idm,jdm,ijdm,4);
Ot   = binaryread(file4,ids,jds,ijds,16);

Rot   = Vort./f;

w  = wt(Y1:Y2,X1:X2);
Ro = Rot(Y1:Y2,X1:X2);
Ri = Rit(Y1:Y2,X1:X2);
%F  = Ft(Y1:Y2,X1:X2);
O  = Ot(:,:);

'plotting...'

%%%%%%%%%% F
% maxF   = quantile(F(~isnan(F)),.95);
% minF   = quantile(F(~isnan(F)),.05);

% ch = figure();
% [p1,p1] = contourf(lon,lat,F,50);
%% p1 = imagesc(lon,lat,F);
% set(p1,'LineStyle','none');

% %set(ch,'edgecolor','none');
%% load('OWColorMap.mat','mycmap')
%% set(ch,'Colormap',mycmap)
% colorbar
% caxis([minF maxF])
% axis image;
% axis xy;

%if(timeid == 1 || timeid == 3)
% title('F','FontSize',24)
%end
% ylabel('Latitude','FontSize',21)
% xlabel('Longitude','FontSize',21)
% set(gca,'FontSize',21)
% cb = colorbar;
% set(cb, 'FontSize',21)
% axis image


% label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_F.eps')
% 'saving...'
% print(ch,'-dpsc2',label);
% close all;

%%%%%%%%%% Ro
 ch = figure();
 imagesc(lon,lat,Ro);
 %set(ch,'edgecolor','none');
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
 colorbar
 caxis([-0.7 0.7])
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


 label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_Ro.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;


%%%%%%%%%%% Ri

 maxRi   = quantile(Ri(~isnan(Ri)),.9);
 minRi   = quantile(Ri(~isnan(Ri)),.1);

 maxRi   = 1;
 minRi   = 0;

 RiN = Ri;
 RiN(Ri > 1) = NaN;
 RiN(Ri < 0) = NaN;

 ch = figure();
 [f0,f0] = contourf(lon,lat,RiN,20);
 set(f0,'edgecolor','none');
% imagesc(lon,lat,Ri);
 axis xy;
 hold on;
 colormap('Autumn');

% plot Ri values for instabilities
% [r0,r0] = contour(lon,lat,Ri,[0.25 0.25]);
% set(r0,'Color',[0.5 0.5 0.5],'LineWidth',5,'LineStyle','-','ShowText','off');

% [r1,r1] = contour(lon,lat,Ri,[1 1]);
% set(r1,'Color',[1 1 1],'LineWidth',5,'LineStyle','-','ShowText','off');

 caxis([minRi maxRi]);

if(timeid == 1 || timeid == 3)
 title('Ri','FontSize',24)
end
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image

 label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_Ri.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;


%%%%%%%%% RiRo^2

 RiRo2 = Ri.*(Ro.^2);

 RiRo2N = RiRo2;
 RiRo2N(RiRo2 > 2)   = NaN;
 RiRo2N(RiRo2 < 0.5) = NaN;


 maxRiRo2   = quantile(RiRo2(~isnan(RiRo2)),.9);
 minRiRo2   = quantile(RiRo2(~isnan(RiRo2)),.1);

 ch = figure();
 p1 = imagesc(lon,lat,RiRo2);
 axis xy;
 caxis([minRiRo2 maxRiRo2])
 colormap(cool);
 colorbar;

 hold on;
 [r0,r0] = contour(lon,lat,RiRo2,[1 1]);
 set(r0,'Color',[0 0 0],'LineWidth',3,'LineStyle','-','ShowText','off');

if(timeid == 1 || timeid == 3)
 title('RiRo^2','FontSize',24)
end
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image



 label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_RiRo.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;

%%%%%%%%%% w

% maxw = quantile(w(~isnan(w)),0.99)
% minw = quantile(w(~isnan(w)),0.01)

 maxw =  5*10^-4;
 minw = -5*10^-4;

 ch = figure();
 imagesc(lon,lat,w);
 axis xy;
 caxis([minw maxw])
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
 colorbar;

if(timeid == 1 || timeid == 3)
 title('w','FontSize',24)
end
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image


 label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_w.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;


%%%%%%%%%% O

% maxw = quantile(w(~isnan(w)),0.99)
% minw = quantile(w(~isnan(w)),0.01)

 maxO =  1*10^-4;
 minO = -1*10^-4;

 ch = figure();
 imagesc(lon,lat,O);
 axis xy;
 caxis([minO maxO])
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
 colorbar;

if(timeid == 1 || timeid == 3)
 title('\omega','FontSize',24)
end
 ylabel('Latitude','FontSize',21)
 xlabel('Longitude','FontSize',21)
 set(gca,'FontSize',21)
 cb = colorbar;
 set(cb, 'FontSize',21)
 axis image


 label = strcat('./plot/front_h_016_archv.',lyear,'_',lday,'_',hd,'_O.eps')
 'saving...'
 print(ch,'-dpsc2',label);
 close all;


end
end
