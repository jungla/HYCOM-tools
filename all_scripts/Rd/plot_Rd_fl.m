clear; close all;
%%%% dimensions  
gridbfid=fopen('../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);

ijdm=idm*jdm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% field indices in the archv file minus 1 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);


for time  = 1:2

day   = textread('../3D/archivesDay_fl');
year  = textread('../3D/archivesYear_fl');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

file1 = strcat('./output/high-res/rd_h_016_archv.',lyear,'_',lday,'_00.a');

Rdt = binaryread(file1,idm,jdm,ijdm,1);

'plotting...'

for region = 1:2

[X1,X2,Y1,Y2,G] = regions_fl(region,time);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

Rd = Rdt(Y1:Y2,X1:X2);

Rd = smooth2(Rd,2);

%Rd(Rd < 0) = NaN;
Rd = abs(Rd);
Rd = sqrt(Rd)/1000;
rdmax = quantile(Rd(~isnan(Rd)),0.95);
%%%%%%%%%%%%%%%%%%% plot

[ch] = figure;
[p1,p1] = contourf(lon,lat,Rd,50);
% p1 = imagesc(lon,lat,Rd);
set(p1,'LineStyle','none');

caxis([0 rdmax])
axis image;
axis xy;
xlabel('Longitude','FontSize',18);
ylabel('Latitude','FontSize',18);
set(gca,'FontSize',18)
cb = colorbar;
set(cb, 'FontSize',18)

label = strcat('./plot/high-res/Rd_h_016_archv.',lyear,'_',lday,'_',G,'_00.a.eps')
%title(['Rossby deformation radius ML (km), HR, day: ',lday,' year:',lyear]);
title(['Rd_{ML}'],'FontSize',18);

print(ch,'-dpsc2',label);

close all;

end
end
