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

N = 22;

X1 = 1
Y1 = 1
X2 = 1573
Y2 = 1073
R = 'T'

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 1:1

for time  = 2:2

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_2');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:1

depth = readline('/tamay/mensa/hycom/scripts/3D/layersDepth_4',did);
depthid = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_4',did));
depth


if (arch == 1)
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter_T/output/high-res/filter_A_h_016_archv.',lyear,'_',lday,'_00_u.a');
 fileuo   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zu.A');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter_T/output/high-res/filter_A_h_016_archv.',lyear,'_',lday,'_00_v.a');
 filevo   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zv.A');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_A_h_016_archv.',lyear,'_',lday,'_00_w.a');
 filewo   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zw.A');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_A_h_016_archv.',lyear,'_',lday,'_00_r.a');
 filero   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
else
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_A_l_016_archv.',lyear,'_',lday,'_00_u.a');
 fileuo   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zu.A');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_A_l_016_archv.',lyear,'_',lday,'_00_v.a');
 filevo   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zv.A');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_A_l_016_archv.',lyear,'_',lday,'_00_w.a');
 filewo   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zw.A');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_A_l_016_archv.',lyear,'_',lday,'_00_r.a');
 filero   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
end

xc = 1;
yc = 1;

ftu = binaryread(fileu,idm,jdm,ijdm,depthid);
ftv = binaryread(filev,idm,jdm,ijdm,depthid);
ftw = binaryread(filew,idm,jdm,ijdm,depthid);
ftr = binaryread(filer,idm,jdm,ijdm,depthid);
ftuo = binaryread(fileuo,idm,jdm,ijdm,depthid);
ftvo = binaryread(filevo,idm,jdm,ijdm,depthid);
ftwo = binaryread(filewo,idm,jdm,ijdm,depthid);
ftro = binaryread(filero,idm,jdm,ijdm,depthid);

fuf  = ftu(Y1:Y2,X1:X2);
fvf  = ftv(Y1:Y2,X1:X2);
fwf  = ftw(Y1:Y2,X1:X2);
frf  = ftr(Y1:Y2,X1:X2);
fuo  = ftuo(Y1:Y2,X1:X2);
fvo  = ftvo(Y1:Y2,X1:X2);
fwo  = ftwo(Y1:Y2,X1:X2);
fro  = ftro(Y1:Y2,X1:X2);

fur = fuo - fuf;
fvr = fvo - fvf;
fwr = fwo - fwf;
frr = fro - frf;

%filter  = smoothc(filtert(Y1:Y2,X1:X2),xc,yc);

h = 0.9
l = 0.1

%%%%%%%%%%%%%%%%%%%%%% filter eke

 ekeo = (fuo.*fvo).^2;
 eker = ekeo - (fuf.*fvf).^2;
 ekef = (fuf.*fvf).^2;

 maxekeo  = quantile(ekeo(~isnan(ekeo)),h);
 minekeo  = quantile(ekeo(~isnan(ekeo)),l);

 maxekef  = quantile(ekef(~isnan(ekef)),h);
 minekef  = quantile(ekef(~isnan(ekef)),l);

 maxeker  = quantile(eker(~isnan(eker)),h);
 mineker  = quantile(eker(~isnan(eker)),l);

 [ch] = figure();
 
 imagesc(lon,lat,ekef);
% [p1,p1] = contourf(lon,lat,ekef,50);
% set(p1,'LineStyle','none');
 axis xy;
 colorbar;
 caxis([minekef maxekef]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_A_',depth,'_',lyear,'_',lday,'_h_',R,'_ekef.eps')
else
 label = strcat('./plot/low-res/filter_A_',depth,'_',lyear,'_',lday,'_l_',R,'_ekef.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


 [ch] = figure();
 imagesc(lon,lat,eker);
% [p1,p1] = contourf(lon,lat,eker,50);
% set(p1,'LineStyle','none');
 axis xy;
 colorbar;
 caxis([mineker maxeker]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_A_',depth,'_',lyear,'_',lday,'_h_',R,'_eker.eps')
else
 label = strcat('./plot/low-res/filter_A_',depth,'_',lyear,'_',lday,'_l_',R,'_eker.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


 [ch] = figure();
 imagesc(lon,lat,ekeo);
% [p1,p1] = contourf(lon,lat,ekeo,50);
% set(p1,'LineStyle','none');

 axis xy;
 colorbar;
 caxis([minekeo maxekeo]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_A_',depth,'_',lyear,'_',lday,'_h_',R,'_ekeo.eps')
else
 label = strcat('./plot/low-res/filter_A_',depth,'_',lyear,'_',lday,'_l_',R,'_ekeo.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


 %orient landscape;

%%%%%%%%%%%%%%%%%%%%%% filter u

 maxfuf  = quantile(fuf(~isnan(fuf)),.99);
 minfuf  = quantile(fuf(~isnan(fuf)),.01);

 maxfur  = quantile(fur(~isnan(fur)),.99);
 minfur  = quantile(fur(~isnan(fur)),.01);

 maxfuo  = quantile(fuo(~isnan(fuo)),.99);
 minfuo  = quantile(fuo(~isnan(fuo)),.01);


 [ch] = figure();
 imagesc(lon,lat,fuf);
 axis xy;
 colorbar;
 caxis([minfuf maxfuf]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_A_',depth,'_',lyear,'_',lday,'_h_',R,'_fuf.eps')
else
 label = strcat('./plot/low-res/filter_A_',depth,'_',lyear,'_',lday,'_l_',R,'_fuf.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
 imagesc(lon,lat,fur);
 axis xy;
 colorbar;
 caxis([minfur maxfur]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_A_',depth,'_',lyear,'_',lday,'_h_',R,'_fur.eps')
else
 label = strcat('./plot/low-res/filter_A_',depth,'_',lyear,'_',lday,'_l_',R,'_fur.eps')
end

 [ch] = figure();
 imagesc(lon,lat,fuo);
 axis xy;
 colorbar;
 caxis([minfuo maxfuo]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_A_',depth,'_',lyear,'_',lday,'_h_',R,'_fuo.eps')
else
 label = strcat('./plot/low-res/filter_A_',depth,'_',lyear,'_',lday,'_l_',R,'_fuo.eps')
end



%%%%%%%%%%%%%%%%%%%%%% filter w 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 maxfwf  = quantile(fwf(~isnan(fwf)),.99);
 minfwf  = quantile(fwf(~isnan(fwf)),.01);

 maxfwr  = quantile(fwr(~isnan(fwr)),.99);
 minfwr  = quantile(fwr(~isnan(fwr)),.01);
    
 [ch] = figure();
 imagesc(lon,lat,fwf);
 axis xy; 
 colorbar;
 caxis([minfwf maxfwf]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_A_',depth,'_',lyear,'_',lday,'_h_',R,'_fwf.eps')
else
 label = strcat('./plot/low-res/filter_A_',depth,'_',lyear,'_',lday,'_l_',R,'_fwf.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
 imagesc(lon,lat,fwr);
 axis xy;
 colorbar;
 caxis([minfwr maxfwr]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_A_',depth,'_',lyear,'_',lday,'_h_',R,'_fwr.eps')
else
 label = strcat('./plot/low-res/filter_A_',depth,'_',lyear,'_',lday,'_l_',R,'_fwr.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


end % depth
end % end day
end % end arch

