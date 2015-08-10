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

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

%tpscx = reshape(tpscx,idm,jdm);
%tpscy = reshape(tpscy,idm,jdm);
%tlon = reshape(tlon,idm,jdm);
%tlat = reshape(tlat,idm,jdm);

lon = tlon(1,:);
lat = tlat(:,1);

 file1 = './depth_GSa0.02_08.a' 

 tml = hycomread(file1,idm,jdm,ijdm,1);
% tml = reshape(tml,idm,jdm);
 tml(tml > 10000) = 10;

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
 contour(lon,lat,tml);
 [p2,p2] = contour(lon,lat,land);
 set(p2,'Color',[0.5 0.5 0.5]);


for region = 1:1

[X1,X2,Y1,Y2,R] = regions_lcs(region)

%%%%%% plot over topography

 x1 = [lon(1,X1) lon(1,X2)];
 x2 = [lon(1,X1) lon(1,X1)];
 x3 = [lon(1,X2) lon(1,X2)];
 y1 = [lat(Y1,1) lat(Y1,1)];
 y2 = [lat(Y2,1) lat(Y2,1)];
 y3 = [lat(Y1,1) lat(Y2,1)];


 line(x1,y1,'LineStyle','-','Color','k');
 line(x1,y2,'LineStyle','-','Color','k');
 line(x2,y3,'LineStyle','-','Color','k');
 line(x3,y3,'LineStyle','-','Color','k');

 text(lon(1,X1)+0.5, lat(Y1,1)+0.5, R,'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color','k'); 


end

% colorbar;
 colormap('bone');
 label = strcat('regions_lcs.eps')
% title('Regions of interest');
 xlabel('Longitude');
 ylabel('Latitude');
 axis image;
 axis xy;

 print(ch,'-dpsc2',label);
 close all;

