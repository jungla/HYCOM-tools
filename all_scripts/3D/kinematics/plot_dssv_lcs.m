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

% plot regions

for arch  = 2:2

for time  = 1:22

for hour  = 2:2

if hour == 1
 hr = '00'
else
 hr = '12'
end 

if arch == 1
 day   = textread('../archivesDay_all_h_l01');
 year  = textread('../archivesYear_all_h_l01');
else
 day   = textread('../archivesDay_all_l_l01');
 year  = textread('../archivesYear_all_l_l01');
end

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for region = 1:2

if str2num(lyear) == 8 
 season = 1
else
 season = 2
end

region
season

[X1,X2,Y1,Y2,R,lcs] = regions_lcs(region,season,arch);

ids = X2-X1;
jds = Y2-Y1;
ijds = ids*jds;


lon = tlon(1,X1:X2-1);
lat = tlat(Y1:Y2-1,1);

for did = 1:1

depth = readline('../layersDepth_3_l01',did);
depthid = readline('../layersDepthID_3_l01',did);

depth

for i = 4:4
    
if(i == 1)
    label = 'divergence'
end

if(i == 2)
    label = 'shearing'
end

if(i == 3)
    label = 'stretching'
end

if(i == 4)
    label = 'vorticity'
end

if(i == 5)
    label = 'okuboweiss'
end


if arch == 1
 file = strcat('./output/high-res/',label,'_h_l01_archv.',lyear,'_',lday,'_',R,'_',hr,'.a');
else
 file = strcat('./output/low-res/',label,'_l_l01_archv.',lyear,'_',lday,'_',R,'_',hr,'.a');
end

 vort = binaryread(file,ids,jds,ijds,depthid);

 if (i == 5)
  vort = vort./((8*10^-5)^2);
 else
  vort = vort./(8*10^-5);
 end

% vort(isnan(vort)) = 0;
'plotting...';

% x1 = [lon(1,Xs1) lon(1,Xs2)];
% x2 = [lon(1,Xs1) lon(1,Xs1)];
% x3 = [lon(1,Xs2) lon(1,Xs2)];
% y1 = [lat(Ys1,1) lat(Ys1,1)];
% y2 = [lat(Ys2,1) lat(Ys2,1)];
% y3 = [lat(Ys1,1) lat(Ys2,1)];

 ch = figure();

 imagesc(lon,lat,vort);

% line(x1,y1,'Color','k');
% line(x1,y2,'Color','k');
% line(x2,y3,'Color','k');
% line(x3,y3,'Color','k');

% [p1,p1] = contourf(lon,lat,vort,50);
% set(p1,'LineStyle','none');
 axis xy;
 axis image;

 xlabel('Longitude','Fontsize',21);
 ylabel('Latitude','Fontsize',21);
 set(gca,'FontSize',18)
 cb = colorbar;
 set(cb, 'FontSize',18)

 load('VortColormap','mycmap')
 set(ch,'Colormap',mycmap)

if (i == 5) 
 caxis([-0.2 0.2]);
 load('OWColorMap','mycmap')
 set(ch,'Colormap',mycmap)
else
 caxis([-1 1]);
end

if arch == 1
  title(['\zeta/f_0, HR, day ',num2str(str2num(lday)),' ',hr],'Fontsize',21);
  label = strcat('./plot/',label,'_h_',lyear,'_',lday,'_',depth,'_',R,'_',hr,'_lcs','.eps')
else
  title(['\zeta/f_0, LR, day ',num2str(str2num(lday)),' ',hr],'Fontsize',21);
  label = strcat('./plot/',label,'_l_',lyear,'_',lday,'_',depth,'_',R,'_',hr,'_lcs','.eps')
end

 print(ch,'-dpsc2',label);

close all;

end
end
end
end
end
end
