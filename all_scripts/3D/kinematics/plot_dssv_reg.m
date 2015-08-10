clear; close all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');

line1 = fgetl(gridbfid);
idm  = sscanf(line1,'%f',1);
line1 = fgetl(gridbfid);
jdm  = sscanf(line1,'%f',1);

ijdm=idm*jdm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

% subregion

Xs1 = 126;
Xs2 = 177;
Ys1 = 108;
Ys2 = 168;


% plot regions

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for arch = 2:2

for time  = 1:2
%for time  = 1:49

day   = textread('../../3D/archivesDay_2');
year  = textread('../../3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did =1:2:3

depth = readline('../../3D/layersDepth_4',did);
depthid = str2num(readline('../../3D/layersDepthID_4',did));
depth

depth

for i=4:4
    
if(i==1)
    label = 'divergence'
end

if(i==2)
    label = 'shearing'
end

if(i==3)
    label = 'stretching'
end

if(i==4)
    label = 'vorticity'
end

if (arch == 1)
 filer = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
 file = strcat('./output/high-res/',label,'_h_016_archv.',lyear,'_',lday,'_00.a');
else
 filer = strcat('../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
 file = strcat('./output/low-res/',label,'_l_016_archv.',lyear,'_',lday,'_00.a');
end

tvort = binaryread(file,idm,jdm,ijdm,depthid);
tRho  = binaryread(filer,idm,jdm,ijdm,depthid);

vort = tvort(Y1:Y2,X1:X2)/(8*10^-5);
Rho  =  tRho(Y1:Y2,X1:X2);
'plotting...';

 x1 = [lon(1,Xs1) lon(1,Xs2)];
 x2 = [lon(1,Xs1) lon(1,Xs1)];
 x3 = [lon(1,Xs2) lon(1,Xs2)];
 y1 = [lat(Ys1,1) lat(Ys1,1)];
 y2 = [lat(Ys2,1) lat(Ys2,1)];
 y3 = [lat(Ys1,1) lat(Ys2,1)];

 ch = figure();


 

% line(x1,y1,'Color','k');
% line(x1,y2,'Color','k');
% line(x2,y3,'Color','k');
% line(x3,y3,'Color','k');

% imagesc(lon,lat,vort);
 [p1,p1] = contourf(lon,lat,vort,50);
 set(p1,'LineStyle','none');
 hold on;
 cb = colorbar;
% [r,r] = contour(lon,lat,Rho)
% set(r, 'Color',[0 0 0],'LineStyle','-','ShowText','off','LineWidth',1)
 axis xy;
 axis image;

% title([label,', day ',lday,', year ',lyear]);

xlabel('Longitude','Fontsize',15);
ylabel('Latitude','Fontsize',15);
 set(gca,'FontSize',14)
 set(cb, 'FontSize',14)

 load('VortColormap','mycmap')
 set(ch,'Colormap',mycmap)

 caxis([-1 1]);

 if(arch == 1)
  label = strcat('./plot/',label,'_h_016_archv.',lyear,'_',lday,'_',depth,'_',R,'_00.a','.eps')
 else
  label = strcat('./plot/',label,'_l_016_archv.',lyear,'_',lday,'_',depth,'_',R,'_00.a','.eps')
 end

 print(ch,'-dpsc2',label);

close all;

end
end
end
end
end
