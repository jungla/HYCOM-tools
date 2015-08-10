clear all;

gridbfid=fopen('./regional.grid.b','r');
line1 = fgetl(gridbfid);
idm  = sscanf(line1,'%f',1);
line1 = fgetl(gridbfid);
jdm  = sscanf(line1,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region

ijdm = idm*jdm;

file = './regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

lon = tlon(1,:);
lat = tlat(:,1);


 file1 = './depth_GSa0.02_08.a' 

 tml = hycomread(file1,idm,jdm,ijdm,1);

 land = zeros(idm,jdm);
 
 land(:,:) = 0;
 land(tml == 10) = 1;

% for i = 1:idm
%     for j = 1:jdm
%         if(tml(i,j) == 10)
%         land(i,j) = 1;
%         else
%         land(i,j) = 0;
%         end
%     end
% end

 ch = figure();
 hold on;
 [p1,p1] = contourf(tlon,tlat,tml);
 set(p1,'edgecolor','none');

% set(gca,'XTick', 1:5:size(tlon(1,:)));


for s = 1:2

for region = 5:5

if (s == 1)
[X1,X2,Y1,Y2,R] = regions(region);
else
 if (region == 5)
 [X1,X2,Y1,Y2,R] = regions_s(1);
 else 
 [X1,X2,Y1,Y2,R] = regions_s(region);
 end
end

%%%%%% plot over topography

 x1 = [lon(1,X1) lon(1,X2)];
 x2 = [lon(1,X1) lon(1,X1)];
 x3 = [lon(1,X2) lon(1,X2)];
 y1 = [lat(Y1,1) lat(Y1,1)];
 y2 = [lat(Y2,1) lat(Y2,1)];
 y3 = [lat(Y1,1) lat(Y2,1)];

if (s == 1)

 line(x1,y1,'LineStyle','-','Color','r');
 line(x1,y2,'LineStyle','-','Color','r');
 line(x2,y3,'LineStyle','-','Color','r');
 line(x3,y3,'LineStyle','-','Color','r');

 text(lon(1,X1)+0.5, lat(Y1,1)+0.5, R,'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color','r'); 

else

if (R == 'As')
 line(x1,y1,'LineStyle','-','Color','r');
 line(x1,y2,'LineStyle','-','Color','r');
 line(x2,y3,'LineStyle','-','Color','r');
 line(x3,y3,'LineStyle','-','Color','r');

 text((lon(1,X2)+lon(1,X1))*0.5, (lat(Y2,1)+lat(Y1,1))*0.5,'S','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color','r'); 
end

% line([lon(472,1) lon(800,1)],[lat(1,80) lat(1,80)],'LineStyle','-','Color','b');
% line([lon(800,1)  lon(800,1)],[lat(1,80) lat(1,272)],'LineStyle','-','Color','b');
% line([lon(800,1)  lon(472,1)],[lat(1,272) lat(1,272)],'LineStyle','-','Color','b');
% line([lon(472,1)  lon(472,1)],[lat(1,272) lat(1,80)],'LineStyle','-','Color','b');

end

end % end region
end % end s_region

% colorbar;
 colormap('bone');
 label = strcat('regions_map.eps')
% title('Regions of interest');
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 set(gca,'XTickLabel',['80W';'75W';'70W';'65W';'60W';'55W'],'FontSize',14)
 set(gca,'YTickLabel',['30N';'35N';'40N';'45N'],'FontSize',14)
 axis image;
 axis xy;

 print(ch,'-dpsc2',label);
%close all;

