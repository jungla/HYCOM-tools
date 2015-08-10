clear all;

gridbfid=fopen('./ATLg0.08/regional.grid.b','r');
line1 = fgetl(gridbfid);
idm  = sscanf(line1,'%f',1);
line1 = fgetl(gridbfid);
jdm  = sscanf(line1,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region

ijdm = idm*jdm;

file = './ATLg0.08/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

lon = tlon(1,:);
lat = tlat(:,1);

 file1 = './ATLg0.08/regional.depth.a' 

 tml = hycomread(file1,idm,jdm,ijdm,1);

 land = zeros(jdm,idm);
 
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

%%%%%% plot over topography

 y1 = [28.78642 45.71742];
 y2 = [28.78642 28.78642];
 y3 = [45.71742 45.71742];
 x1 = [278.56000 278.56000];
 x2 = [310.00000 310.00000];
 x3 = [278.56000 310.00000];


 line(x1,y1,'LineStyle','-','Color','r');
 line(x3,y2,'LineStyle','-','Color','r');
 line(x2,y1,'LineStyle','-','Color','r');
 line(x3,y3,'LineStyle','-','Color','r');

 text(278.5,-12, 'LR','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color','k'); 
 text(282.7,43, 'HR','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color','r'); 


% line(x1,y1,'LineStyle','-','Color',[0.5 0.5 0.5]);
% line(x1,y2,'LineStyle','-','Color',[0.5 0.5 0.5]);
% line(x2,y3,'LineStyle','-','Color',[0.5 0.5 0.5]);
% line(x3,y3,'LineStyle','-','Color',[0.5 0.5 0.5]);

% text((lon(X2,1)+lon(X1,1))*0.5, (lat(1,Y2)+lat(1,Y1))*0.5,'S','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color',[0.5 0.5 0.5]); 

% line([lon(472,1) lon(800,1)],[lat(1,80) lat(1,80)],'LineStyle','-','Color','b');
% line([lon(800,1)  lon(800,1)],[lat(1,80) lat(1,272)],'LineStyle','-','Color','b');
% line([lon(800,1)  lon(472,1)],[lat(1,272) lat(1,272)],'LineStyle','-','Color','b');
% line([lon(472,1)  lon(472,1)],[lat(1,272) lat(1,80)],'LineStyle','-','Color','b');






% colorbar;
 colormap('bone');
 label = strcat('regions_map_all.eps')
% title('Regions of interest');
 ylabel('Latitude','FontSize',18)
 xlabel('Longitude','FontSize',18)
 set(gca,'XTickLabel',['100W';'80W ';'60W ';'40W ';'20W ';'0E  ';'20E ';'40E '],'FontSize',14)
 set(gca,'YTickLabel',['20S';'10S';'EQ ';'10N';'20N';'30N';'40N';'50N';'60N';'70N'],'FontSize',14)
 axis xy;

 print(ch,'-dpsc2',label);
 close all;

