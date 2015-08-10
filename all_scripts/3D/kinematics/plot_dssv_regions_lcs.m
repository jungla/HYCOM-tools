clear all;

gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line1 = fgetl(gridbfid);
idm  = sscanf(line1,'%f',1);
line1 = fgetl(gridbfid);
jdm  = sscanf(line1,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region

ijdm = idm*jdm;

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

lon = tlon(1,:);
lat = tlat(:,1);

% set(gca,'XTick', 1:5:size(tlon(1,:)));

for arch = 1:2

for time = 1:2

if arch == 1
 day   = textread('../../3D/archivesDay_2_h_lcs');
 year  = textread('../../3D/archivesYear_2_h_lcs');
else
 day   = textread('../../3D/archivesDay_2_l_lcs');
 year  = textread('../../3D/archivesYear_2_l_lcs');
end
 
 lday  = digit(day(time),3);
 lyear = digit(year(time),4);
 
 lday
 lyear

if arch == 1
 file = strcat('./output/high-res/vorticity_a_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file = strcat('./output/low-res/vorticity_a_l_016_archv.',lyear,'_',lday,'_00.a');
end

 tvort = binaryread(file,idm,jdm,ijdm,1);
 tvort(isnan(tvort)) = 0;
 vort = tvort/(8*10^-5);

 ch = figure();
 hold on;
 p1 = imagesc(tlon(1,:),tlat(:,1),vort);
 colorbar

for region = 1:2:5 %1:2:5

[X1,X2,Y1,Y2,R,lcs] = regions_lcs(region+time,arch);

%%%%%% plot over topography

 x1 = [lon(1,X1) lon(1,X2)];
 x2 = [lon(1,X1) lon(1,X1)];
 x3 = [lon(1,X2) lon(1,X2)];
 y1 = [lat(Y1,1) lat(Y1,1)];
 y2 = [lat(Y2,1) lat(Y2,1)];
 y3 = [lat(Y1,1) lat(Y2,1)];


 line(x1,y1,'LineStyle','-','Color','k','LineWidth',1.5);
 line(x1,y2,'LineStyle','-','Color','k','LineWidth',1.5);
 line(x2,y3,'LineStyle','-','Color','k','LineWidth',1.5);
 line(x3,y3,'LineStyle','-','Color','k','LineWidth',1.5);

 text(lon(1,X1)+1.5, lat(Y1,1)+1.5, R,'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color','k'); 

end % end region

% colorbar;
 load('VortColormap','mycmap')
 set(ch,'Colormap',mycmap)

 caxis([-1 1]);

if arch == 1
 label = strcat('./plot/regions_map_lcs_h_',lyear,'_',lday,'.eps')
else
 label = strcat('./plot/regions_map_lcs_l_',lyear,'_',lday,'.eps')
end

 title('\zeta/f_0','FontSize',21);
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 set(gca,'XTickLabel',['80W';'75W';'70W';'65W';'60W';'55W'],'FontSize',14)
 set(gca,'YTickLabel',['30N';'35N';'40N';'45N'],'FontSize',14)
 axis image;
 axis xy;

 print(ch,'-dpsc2',label);
%close all;

end % season
end % arch
