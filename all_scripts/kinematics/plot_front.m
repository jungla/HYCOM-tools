clear; close all;
%%%% dimensions  
gridbfid=fopen('../regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../topo0.02/regional.grid.a';

lon = hycomread(file,idm,jdm,ijdm,1);
lat = hycomread(file,idm,jdm,ijdm,2);

Y1 = 128;
Y2 = 246;
X1 = 1032;
X2 = 1122;

lon = lon(1,X1:X2);
lat = lat(Y1:Y2,1);

%lat = flipdim(lat,2);

day  = 306;
year = 8;

for timeid = 1:20
day = day + 1;

for t = 1:2


lday  = digit(day,3)
lyear = digit(year,4)

if(t == 1)
 hd = '00'
else
 hd = '12'
end

file = strcat('./output/dssv/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_',hd,'.a');
vortt = hycomread(file,idm,jdm,ijdm,1);
vort = vortt(Y1:Y2,X1:X2)./(8*10^-5);

'plotting...'
ch = figure();
imagesc(lon,lat,vort);
%set(ch,'edgecolor','none');
axis image;
axis xy;

%title(['front day:',lday,' ',hd]);
colorbar
caxis([-1 2])

label = strcat('front_h_016_archv.',lyear,'_',lday,'_',hd,'.eps');
'saving...'

 print(ch,'-dpsc2',label);

close
end
end
