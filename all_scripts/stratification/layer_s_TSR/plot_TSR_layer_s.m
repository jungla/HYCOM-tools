clear; close all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line1=fgetl(gridbfid);
idm=sscanf(line1,'%f',1);
line1=fgetl(gridbfid);
jdm=sscanf(line1,'%f',1);

ijdm=idm*jdm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% field indices in the archv file minus 1 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);


lday = '';

N = '1';

for arch = 1:2

for time  = 1:2

day   = textread('../../3D/archivesDay_2');
year  = textread('../../3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

if(arch == 1)
file1 = strcat('./output/',N,'/high-res/layer_s_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_R_00.a');
file2 = strcat('./output/',N,'/high-res/layer_s_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_S_00.a');
file3 = strcat('./output/',N,'/high-res/layer_s_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_T_00.a');
else
file1 = strcat('./output/',N,'/low-res/layer_s_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_R_00.a');
file2 = strcat('./output/',N,'/low-res/layer_s_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_S_00.a');
file3 = strcat('./output/',N,'/low-res/layer_s_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_T_00.a');
end

Rt = hycomread(file1,idm,jdm,ijdm,1);
St = hycomread(file2,idm,jdm,ijdm,1);
Tt = hycomread(file3,idm,jdm,ijdm,1);

'plotting...'
file

for region = 1:1

[X1,X2,Y1,Y2,G] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

R = Rt(Y1:Y2,X1:X2);
T = Tt(Y1:Y2,X1:X2);
S = St(Y1:Y2,X1:X2);

R = smooth2(R,2);

%%%%%%%%%%%%%%%%%%%%% density

[ch] = figure;
%imagesc(lon,lat,R);

[p1,p1] = contourf(lon,lat,R,100);
% p1 = imagesc(lon,lat,Ro);
axis xy;
set(p1,'LineStyle','none');


axis image;
caxis([quantile(R(~isnan(R)),0.1), quantile(R(~isnan(R)),0.9)])
%caxis([31.7 33.7])


axis xy;

%title('\sigma','FontSize',15)
ylabel('Latitude','FontSize',15)
xlabel('Longitude','FontSize',15)
set(gca,'FontSize',15)
cb = colorbar;
set(cb, 'FontSize',15)

if time == 2
 l1 = 32.1;
 text(lon(1,1)+0.2,l1+0.2, 'A','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');
 text(lon(1,end)-0.2,l1+0.2, 'A''','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');
else
 l1 = 32.7;
 text(lon(1,1)+0.2,l1+0.2, 'B','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');
 text(lon(1,end)-0.2,l1+0.2, 'B''','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'Color','k');
end

lsec =  find(lat(:,:) > l1,1);

% plot line section
 x1 = [lon(1,1) lon(1,end)];
 y1 = [lat(lsec,1) lat(lsec,1)];

 line(x1,y1,'LineStyle','-','Color','k','LineWidth',1.5);


if(arch == 1)
label = strcat('./plot/',N,'/high-res/layer_s_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_',G,'_R_00.a.eps')
%title(['Density, layer ',N,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/',N,'/low-res/layer_s_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_',G,'_R_00.a.eps')
%title(['Density, layer ',N,', LR, day: ',lday,' year:',lyear]);
end

print(ch,'-dpsc2',label);

close all;

%%%%%%%%%%%%%%%%%%%%% temperature 

[ch] = figure;
imagesc(lon,lat,T);

axis image;
axis xy;
ylabel('Latitude','FontSize',13)
xlabel('Longitude','FontSize',13)
set(gca,'FontSize',13)
cb = colorbar;
set(cb, 'FontSize',13)


if(arch == 1)
label = strcat('./plot/',N,'/high-res/layer_s_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_',G,'_T_00.a.eps')
%title(['Temperature, layer ',N,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/',N,'/low-res/layer_s_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_',G,'_T_00.a.eps')
%title(['Temperature, layer ',N,', LR, day: ',lday,' year:',lyear]);
end

print(ch,'-dpsc2',label);

close all;

%%%%%%%%%%%%%%%%%%%%% salinity

[ch] = figure;
imagesc(lon,lat,S);

axis image;
axis xy;
ylabel('Latitude','FontSize',13)
xlabel('Longitude','FontSize',13)
set(gca,'FontSize',13)
cb = colorbar;
set(cb, 'FontSize',13)


if(arch == 1)
label = strcat('./plot/',N,'/high-res/layer_s_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_',G,'_S_00.a.eps')
%title(['Salinity, layer ',N,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/',N,'/low-res/layer_s_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_',G,'_S_00.a.eps')
%title(['Salinity, layer ',N,', LR, day: ',lday,' year:',lyear]);
end

print(ch,'-dpsc2',label);

close all;

end
end
end
