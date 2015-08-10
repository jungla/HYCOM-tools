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

tlon = hycomread(file,ijdm,1);
tlat = hycomread(file,ijdm,2);

tpscx = hycomread(file,ijdm,10);
tpscy = hycomread(file,ijdm,11);

tpscx = reshape(tpscx,idm,jdm);
tpscy = reshape(tpscy,idm,jdm);
tlon = reshape(tlon,idm,jdm);
tlat = reshape(tlat,idm,jdm);

lon = tlon(:,1);
lat = tlat(1,:);

 file1 = './depth_GSa0.02_08.a' 

 tml = hycomread(file1,ijdm,1);
 tml = reshape(tml,idm,jdm);
 tml(tml > 10000) = 10;

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
 contour(lon,lat,tml');
 [p2,p2] = contour(lon,lat,land');
 set(p2,'Color',[0.5 0.5 0.5]);


X1 = 900
X2 = 1280
Y1 = 80
Y2 = 400

R = 'A'

%%%%%% plot over topography

 x1 = [lon(X1,1) lon(X2,1)];
 x2 = [lon(X1,1) lon(X1,1)];
 x3 = [lon(X2,1) lon(X2,1)];
 y1 = [lat(1,Y1) lat(1,Y1)];
 y2 = [lat(1,Y2) lat(1,Y2)];
 y3 = [lat(1,Y1) lat(1,Y2)];


 line(x1,y1,'LineStyle','-','Color','k');
 line(x1,y2,'LineStyle','-','Color','k');
 line(x2,y3,'LineStyle','-','Color','k');
 line(x3,y3,'LineStyle','-','Color','k');

 text(lon(X1,1)+0.5, lat(1,Y1)+0.5, R,'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color','k'); 



% colorbar;
 colormap('bone');
 label = strcat('regions_yeon.eps')
% title('Regions of interest');
 xlabel('Longitude');
 ylabel('Latitude');
 axis image;
 axis xy;

 print(ch,'-dpsc2',label);
%close all;

