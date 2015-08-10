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

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

ids = X2-X1+1;
jds = Y2-Y1+1;

ijds = ids*jds;

for arch = 1:1

for time  = 1:2

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_2');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did = 1:1

depth = readline('/tamay/mensa/hycom/scripts/3D/layersDepth_4',did);
depthid = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_4',did));
depth


if (arch == 1)
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_016_archv.',lyear,'_',lday,'_00_u.a');
 fileuo   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zu.A');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_016_archv.',lyear,'_',lday,'_00_v.a');
 filevo   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zv.A');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_016_archv.',lyear,'_',lday,'_00_w.a');
 filewo   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zw.A');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_016_archv.',lyear,'_',lday,'_00_r.a');
 filero   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
else
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_u.a');
 fileuo   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zu.A');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_v.a');
 filevo   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zv.A');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_w.a');
 filewo   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zw.A');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_r.a');
 filero   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
end

xc = 1;
yc = 1;

fuf = binaryread(fileu,ids,jds,ijds,depthid);
fvf = binaryread(filev,ids,jds,ijds,depthid);
fwf = binaryread(filew,ids,jds,ijds,depthid);
frf = binaryread(filer,ids,jds,ijds,depthid);
ftuo = binaryread(fileuo,idm,jdm,ijdm,depthid);
ftvo = binaryread(filevo,idm,jdm,ijdm,depthid);
ftwo = binaryread(filewo,idm,jdm,ijdm,depthid);
ftro = binaryread(filero,idm,jdm,ijdm,depthid);

fuo  = ftuo(Y1:Y2,X1:X2);
fvo  = ftvo(Y1:Y2,X1:X2);
fwo  = ftwo(Y1:Y2,X1:X2);
fro  = ftro(Y1:Y2,X1:X2);

fro = fro + 1000;

fwr = fwo - fwf;
fur = fuo - fuf;
fvr = fvo - fvf;
frr = fro - frf;

%filter  = smoothc(filtert(Y1:Y2,X1:X2),xc,yc);


%%%%%%%%%%%%%%%%%%%%%% filter eke

 ekef = (fuf.*fvf).^2;
 eker = (fur.*fvr).^2;
 ekeo = (fuo.*fvo).^2;

 maxekef  = quantile(ekef(~isnan(ekef)),.95);
 minekef  = quantile(ekef(~isnan(ekef)),.05);

 maxeker  = quantile(eker(~isnan(eker)),.95);
 mineker  = quantile(eker(~isnan(eker)),.05);

 maxekeo  = quantile(ekeo(~isnan(ekeo)),.95);
 minekeo  = quantile(ekeo(~isnan(ekeo)),.05);

 [ch] = figure();
 imagesc(lon,lat,ekef);
 axis xy;
 colorbar;
 caxis([minekef maxekef]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_ekef.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_ekef.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


 [ch] = figure();
 imagesc(lon,lat,eker);
 axis xy;
 colorbar;
 caxis([mineker maxeker]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_eker.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_eker.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
 imagesc(lon,lat,ekeo);
 axis xy;
 colorbar;
 caxis([minekeo maxekeo]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_ekeo.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_ekeo.eps')
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
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_fuf.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_fuf.eps')
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
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_fur.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_fur.eps')
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
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_fuo.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_fuo.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

%%%%%%%%%%%%%%%%%%%%%% filter w 

 maxfwf  = quantile(fwf(~isnan(fwf)),.99);
 minfwf  = quantile(fwf(~isnan(fwf)),.01);

 maxfwr  = quantile(fwr(~isnan(fwr)),.99);
 minfwr  = quantile(fwr(~isnan(fwr)),.01);

 maxfwo  = quantile(fwo(~isnan(fwo)),.99);
 minfwo  = quantile(fwo(~isnan(fwo)),.01);
    
 [ch] = figure();
 imagesc(lon,lat,fwf);
 axis xy; 
 colorbar;
 caxis([minfwf maxfwf]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_fwf.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_fwf.eps')
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
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_fwr.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_fwr.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
 imagesc(lon,lat,fwo);
 axis xy;
 colorbar;
 caxis([minfwo maxfwo]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_fwo.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_fwo.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


%%%%%%%%%%%%%%%%%%%%%% filter r 

 maxfrf  = quantile(frf(~isnan(frf)),.99);
 minfrf  = quantile(frf(~isnan(frf)),.01);

 maxfrr  = quantile(frr(~isnan(frr)),.99);
 minfrr  = quantile(frr(~isnan(frr)),.01);

 maxfro  = quantile(fro(~isnan(fro)),.99);
 minfro  = quantile(fro(~isnan(fro)),.01);

 [ch] = figure();
 imagesc(lon,lat,frf);
 axis xy;
 colorbar;
 caxis([minfrf maxfrf]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_frf.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_frf.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
 imagesc(lon,lat,frr);
 axis xy;
 colorbar;
 caxis([minfrr maxfrr]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_frr.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_frr.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
 imagesc(lon,lat,fro);
 axis xy;
 colorbar;
 caxis([minfro maxfro]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',depth,'_',lyear,'_',lday,'_h_',R,'_fro.eps')
else
 label = strcat('./plot/low-res/filter_',depth,'_',lyear,'_',lday,'_l_',R,'_fro.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

%%%%%%% speed

 co = sqrt(fuo.^2 + fvo.^2);
 cf = sqrt(fuf.^2 + fvf.^2);
 cr = co - cf;
 
 maxco  = quantile(co(~isnan(co)),h);
 minco  = quantile(co(~isnan(co)),l);

 maxcf  = quantile(cf(~isnan(cf)),h);
 mincf  = quantile(cf(~isnan(cf)),l);
 
 maxcr  = quantile(cr(~isnan(cr)),h);
 mincr  = quantile(cr(~isnan(cr)),l);

 [ch] = figure();
 
 imagesc(lon,lat,cf);
% [p1,p1] = contourf(lon,lat,ekef,50);
% set(p1,'LineStyle','none');
 axis xy;
 colorbar;
 caxis([mincf maxcf]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_cf.eps')
else
 label = strcat('./plot/low-res/filter_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_cf.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
 imagesc(lon,lat,cr);
% [p1,p1] = contourf(lon,lat,eker,50);
% set(p1,'LineStyle','none');
 axis xy;
 colorbar;
 caxis([mincr maxcr]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_cr.eps')
else
 label = strcat('./plot/low-res/filter_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_cr.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


 [ch] = figure();
 imagesc(lon,lat,co);
% [p1,p1] = contourf(lon,lat,ekeo,50);
% set(p1,'LineStyle','none');

 axis xy;
 colorbar;
 caxis([minco maxco]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_co.eps')
else
 label = strcat('./plot/low-res/filter_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_co.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;



end % depth
end % end day
end % end arch

end % end region
