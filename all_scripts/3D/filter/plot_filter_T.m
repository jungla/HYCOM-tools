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

for deltaid = 3:3

delta = readline('/tamay/mensa/hycom/scripts/3D/delta_filt',deltaid)

for did = 2:2

depth = readline('/tamay/mensa/hycom/scripts/3D/layersDepth_4',did);
depthid = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_4',did));
depth

if (arch == 1)
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_',delta,'_T_archv.',lyear,'_',lday,'_00_u.a');
 fileuo   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zu.A');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_',delta,'_T_archv.',lyear,'_',lday,'_00_v.a');
 filevo   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zv.A');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_',delta,'_T_archv.',lyear,'_',lday,'_00_w.a');
 filewo   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zw.A');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_',delta,'_T_archv.',lyear,'_',lday,'_00_r.a');
 filero   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
 filet   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/high-res/filter_h_',delta,'_T_archv.',lyear,'_',lday,'_00_t.a');
 fileto   = strcat('/tamay/mensa/hycom/GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zt.A');
else
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_',delta,'_T_archv.',lyear,'_',lday,'_00_u.a');
 fileuo   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zu.A');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_',delta,'_T_archv.',lyear,'_',lday,'_00_v.a');
 filevo   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zv.A');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_',delta,'_T_archv.',lyear,'_',lday,'_00_w.a');
 filewo   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zw.A');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_',delta,'_T_archv.',lyear,'_',lday,'_00_r.a');
 filero   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
 filet   = strcat('/tamay/mensa/hycom/scripts/3D/filter/output/low-res/filter_l_',delta,'_T_archv.',lyear,'_',lday,'_00_t.a');
 fileto   = strcat('/tamay/mensa/hycom/GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zt.A');
end

xc = 1;
yc = 1;

fuf = binaryread(fileu,idm,jdm,ijdm,depthid);
fvf = binaryread(filev,idm,jdm,ijdm,depthid);
fwf = binaryread(filew,idm,jdm,ijdm,depthid);
frf = binaryread(filer,idm,jdm,ijdm,depthid);
ftf = binaryread(filet,idm,jdm,ijdm,depthid);
fuo = binaryread(fileuo,idm,jdm,ijdm,depthid);
fvo = binaryread(filevo,idm,jdm,ijdm,depthid);
fwo = binaryread(filewo,idm,jdm,ijdm,depthid);
fro = binaryread(filero,idm,jdm,ijdm,depthid);
fto = binaryread(fileto,idm,jdm,ijdm,depthid);

fur = fuo - fuf;
fvr = fvo - fvf;
fwr = fwo - fwf;
frr = fro - frf;
ftr = fto - ftf;

%filter  = smoothc(filtert(Y1:Y2,X1:X2),xc,yc);

h = 0.9
l = 0.1

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

 cf = reshape(cf,ijdm,1);
 cf(cf>maxcf)=maxcf;
 cf = reshape(cf,jdm,idm);

 cr = reshape(cr,ijdm,1);
 cr(cr>maxcr)=maxcr;
 cr(cr<mincr)=mincr;
 cr = reshape(cr,jdm,idm);

 co = reshape(co,ijdm,1);
 co(co>maxco)=maxco;
 co = reshape(co,jdm,idm);

 [ch] = figure();

% imagesc(lon,lat,cf);
 [p1,p1] = contourf(lon,lat,cf);
 set(p1,'LineStyle','none');
 axis xy;
 cb = colorbar;
 set(cb, 'FontSize',16)
 caxis([mincf maxcf]);
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 axis image
 title('c_f','FontSize',20)
 set(gca,'FontSize',16)

if (arch == 1)
 label = strcat('./plot/high-res/filter_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_cf.eps')
else
 label = strcat('./plot/low-res/filter_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_cf.eps')
end
 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
% imagesc(lon,lat,cr);
 [p1,p1] = contourf(lon,lat,cr);
 set(p1,'LineStyle','none');
 axis xy;
 cb = colorbar;
 set(cb, 'FontSize',16)
 caxis([mincr maxcr]);
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 axis image
 title('c_r','FontSize',20)
 set(gca,'FontSize',16) 

if (arch == 1)
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_cr.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_cr.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;


 [ch] = figure();
% imagesc(lon,lat,co);
 [p1,p1] = contourf(lon,lat,co);
 set(p1,'LineStyle','none');
 axis xy;
 cb = colorbar;
 set(cb, 'FontSize',16)
 caxis([mincf maxcf])
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 axis image
 title('c','FontSize',20)
 set(gca,'FontSize',16)

if (arch == 1)
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_co.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_co.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;




%%%%%%%%%%%%%%%%%%%%%% filter eke

 ekeo = (fuo.^2 + fvo.^2);
 ekef = (fuf.^2 + fvf.^2);
 eker = ekeo - ekef;

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
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_ekef.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_ekef.eps')
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
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_eker.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_eker.eps')
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
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_ekeo.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_ekeo.eps')
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
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_fuf.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_fuf.eps')
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
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_fur.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_fur.eps')
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
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_fuo.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_fuo.eps')
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
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_fwf.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_fwf.eps')
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
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_fwr.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_fwr.eps')
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
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_fwo.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_fwo.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

%%%%%%%% temperature

 maxftf  = quantile(ftf(~isnan(ftf)),.99);
 minftf  = quantile(ftf(~isnan(ftf)),.01);

 maxftr  = quantile(ftr(~isnan(ftr)),.99);
 minftr  = quantile(ftr(~isnan(ftr)),.01);

 maxfto  = quantile(fto(~isnan(fto)),.99);
 minfto  = quantile(fto(~isnan(fto)),.01);

 [ch] = figure();
 imagesc(lon,lat,ftf);
 axis xy;
 colorbar;
 caxis([minftf maxftf]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_ftf.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_ftf.eps')
end
 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
 imagesc(lon,lat,ftr);
 axis xy;
 colorbar;
 caxis([minftr maxftr]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_ftr.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_ftr.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure();
 imagesc(lon,lat,fto);
 axis xy;
 colorbar;
 caxis([minfto maxfto]);
 ylabel('Latitude','FontSize',12)
 xlabel('Longitude','FontSize',12)
 axis image

if (arch == 1)
 label = strcat('./plot/high-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_h_',R,'_fto.eps')
else
 label = strcat('./plot/low-res/filter_T_',delta,'_',depth,'_',lyear,'_',lday,'_l_',R,'_fto.eps')
end

 'saving...'
 print(ch,'-dpsc2',label)
 close all;



end % depth
end % delta
end % end day
end % end arch
