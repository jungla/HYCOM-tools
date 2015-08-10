clear all;

gridbfid=fopen('/tamay/mensa/hycom/scripts/topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
ijdm = idm*jdm;

file = '/tamay/mensa/hycom/scripts/topo0.02/regional.grid.a';

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

for region = 1:4

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 1:2

for time  = 1:2

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_2');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:4

depth = readline('/tamay/mensa/hycom/scripts/3D/layersDepth_4',did);
depthid = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_4',did));
depth

if (arch == 1)
 file1  = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zw.A');
 file3  = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zu.A');
 file4  = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zv.A');
 file   = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/high-res/twind_h_016_archv.',lyear,'_',lday,'_00.a');
 file5  = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/high-res/u_h_016_archv.',lyear,'_',lday,'_00.a');
 file6  = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/high-res/v_h_016_archv.',lyear,'_',lday,'_00.a');
 file7  = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/high-res/ug_h_016_archv.',lyear,'_',lday,'_00.a');
 file8  = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/high-res/vg_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file1  = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
 file2  = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zw.A');
 file3  = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zu.A');
 file4  = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zv.A');
 file   = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/low-res/twind_l_016_archv.',lyear,'_',lday,'_00.a');
 file5  = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/low-res/u_l_016_archv.',lyear,'_',lday,'_00.a');
 file6  = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/low-res/v_l_016_archv.',lyear,'_',lday,'_00.a');
 file7  = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/low-res/ug_l_016_archv.',lyear,'_',lday,'_00.a');
 file8  = strcat('/tamay/mensa/hycom/scripts/3D/twind/output/low-res/vg_l_016_archv.',lyear,'_',lday,'_00.a');
end

xc = 1;
yc = 1;

twindt = binaryread(file,idm,jdm,ijdm,depthid);
Rhot   = binaryread(file1,idm,jdm,ijdm,depthid);
wt     = binaryread(file2,idm,jdm,ijdm,depthid);
ut     = binaryread(file3,idm,jdm,ijdm,depthid);
vt     = binaryread(file4,idm,jdm,ijdm,depthid);
tut    = binaryread(file5,idm,jdm,ijdm,depthid);
tvt    = binaryread(file6,idm,jdm,ijdm,depthid);

if (depthid == 2)
ugt    = binaryread(file7,idm,jdm,ijdm,1);
vgt    = binaryread(file8,idm,jdm,ijdm,1);
ug      = ugt(Y1:Y2,X1:X2);
vg      = vgt(Y1:Y2,X1:X2);
end

u      = ut(Y1:Y2,X1:X2);
v      = vt(Y1:Y2,X1:X2);
tu     = tut(Y1:Y2,X1:X2);
tv     = tvt(Y1:Y2,X1:X2);
w      = wt(Y1:Y2,X1:X2);
Rho    = Rhot(Y1:Y2,X1:X2);
twind  = twindt(Y1:Y2,X1:X2);

for i=1:X2-X1-1
for j=1:Y2-Y1-1
if(isnan(tu(j,i)) && ~isnan(Rho(j,i)))
i
j
end
end
end

tc = sqrt(tu.^2 + tv.^2);
c  = sqrt(u.^2 + v.^2);

tcc = (tc - c).^2./c.^2;

twwind = sqrt(((w-twind).^2)./w.^2);

 maxtwind   = quantile(twind(~isnan(twind)),.9);
 mintwind   = quantile(twind(~isnan(twind)),.1);
 maxtwwind  = quantile(twwind(~isnan(twwind)),.9);
 mintwwind  = quantile(twwind(~isnan(twwind)),.1);
 maxw       = quantile(w(~isnan(w)),.9);
 minw       = quantile(w(~isnan(w)),.1);
 maxc       = quantile(c(~isnan(c)),.9);
 minc       = quantile(c(~isnan(c)),.1);
 maxtc      = quantile(tc(~isnan(tc)),.9);
 mintc      = quantile(tc(~isnan(tc)),.1);
 maxtcc     = quantile(tcc(~isnan(tcc)),.9);
 mintcc     = quantile(tcc(~isnan(tcc)),.1);

%%%%%%%%%%%%%%%%%%%%%% twind
 [ch] = figure();

% [p1,p1] = contourf(lon,lat,twind,50);
 p1 = imagesc(lon,lat,twind);
 axis xy;
% set(p1,'LineStyle','none');
 colorbar;
 hold on;
 caxis([mintwind maxtwind]);
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
% colormap('Autumn');

% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
% title('twind')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/high-res/twind_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/low-res/twind_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


%%%%%%%%%%%%%%%%%%%%%% twwind
 [ch] = figure();

% [p1,p1] = contourf(lon,lat,twind,50);
 p1 = imagesc(lon,lat,twwind);
 axis xy;
% set(p1,'LineStyle','none');
 colorbar;
 hold on;
 caxis([mintwwind maxtwwind]);
% load('OWColorMap.mat','mycmap')
% set(ch,'Colormap',mycmap)
 colormap('Autumn');

% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
% title('twind')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/high-res/twwind_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/low-res/twwind_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


%%%%%%%%%%%%%%%%%%%%%% w
 [ch] = figure();

% [p1,p1] = contourf(lon,lat,twind,50);
 p1 = imagesc(lon,lat,w);
 axis xy;
% set(p1,'LineStyle','none');
 colorbar;
 hold on;
 caxis([minw maxw]);
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
% colormap('Autumn');

% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
% title('twind')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/high-res/w_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/low-res/w_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

%%%%%%%%%%%%%%%%%%%%%% tc
 [ch] = figure();

% [p1,p1] = contourf(lon,lat,twind,50);
 p1 = imagesc(lon,lat,tc);
 axis xy;
% set(p1,'LineStyle','none');
 colorbar;
 hold on;
 caxis([mintc maxtc]);
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
% colormap('Autumn');

% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
% title('twind')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/high-res/tc_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/low-res/tc_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

%%%%%%%%%%%%%%%%%%%%%% c
 [ch] = figure();

% [p1,p1] = contourf(lon,lat,twind,50);
 p1 = imagesc(lon,lat,c);
 axis xy;
% set(p1,'LineStyle','none');
 colorbar;
 hold on;
 caxis([minc maxc]);
 load('OWColorMap.mat','mycmap')
 set(ch,'Colormap',mycmap)
% colormap('Autumn');

% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
% title('twind')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/high-res/c_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/low-res/c_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


%%%%%%%%%%%%%%%%%%%%%% tcc
 [ch] = figure();

% [p1,p1] = contourf(lon,lat,twind,50);
 p1 = imagesc(lon,lat,tcc);
 axis xy;
% set(p1,'LineStyle','none');
 colorbar;
 hold on;
 caxis([mintcc maxtcc]);
% load('OWColorMap.mat','mycmap')
% set(ch,'Colormap',mycmap)
 colormap('Autumn');

% [p2,p2] = contour(lon,lat,Rho);
% set(p2,'Color',[0.5 0.5 0.5],'ShowText','on','TextStep',get(p2,'LevelStep')*2);
% th = clabel(p2,p2,'Color',[0.5 0.5 0.5],'FontSize',7,'LabelSpacing',72);
% title('twind')
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/high-res/tcc_',depth,'_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('/tamay/mensa/hycom/scripts/3D/twind/plot/low-res/tcc_',depth,'_',lyear,'_',lday,'_l_',R,'.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;



end % depth
end % end day
end % end arch

end % end region
