clear all

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

for arch = 1:2
for time  = 2:2
for region = 3:3 %1:3:5

z_id = [1, 3, 4, 5, 7, 8, 9, 12, 16, 20, 24, 28, 32, 36, 40, 48, 56, 64, 72, 80, 88]
z = z_id.*10 - 9;

for did = 1:4

if did == 1
 depthid = 1;
elseif did == 2
 depthid = 12;
elseif did == 3
 depthid = 32;
elseif did == 4
 depthid = 48;
end

depth = depthid.*10 - 9

[X1,X2,Y1,Y2,R,lsec] = regions_lcs(region+time,arch);

lon = tlon(1,X1:X2-1);
lat = tlat(Y1:Y2-1,1);

if time == 1
 season = 'Sum'
else
 season = 'Win'
end

if arch == 1
 file1 = strcat('./output/fsle_data_',season,R,'_h.mat');
else
 file1 = strcat('./output/fsle_data_',season,R,'_l.mat');
end

load(file1);

if arch == 1
 FB = LiapB(:,:,depthid)';
 FF = LiapF(:,:,depthid)';
else
 FB = LiapB1(:,:,depthid)';
 FF = LiapF1(:,:,depthid)';
end

FB = -FB;

smooth2(FB,3);
smooth2(FF,3);

ch = figure();
load('OWColorMap','mycmap')
set(ch,'Colormap',mycmap)

r = ones(100,1);
g = ones(100,1);
b = ones(100,1);

if time == 1
fM = 0.9
fm = 0.1
else
fM = 0.8
fm = 0.2
end

maxFF = quantile(FF(FF>0),fM); %max(max(FF)); %quantile(FF(~isnan(FF)),.75);
minFF = 0; 

maxFB = 0;
minFB = quantile(FB(FB<0),fm); %min(min(FB)); %quantile(FB(~isnan(FB)),.2);


% build colormap centered on 0

span = abs(maxFF/minFB);

%spanR/spanB = span;
%spanR + snapB = 100;

spanB = ceil(100/(1+span));
spanR = floor(100 - 100/(1+span));

g1 = 0:1/spanR:1;
g2 = 0:1/spanB:1;
g2 = 1 - g2;

b1 = 0:1/spanR:1;
b2 = 1;

r1 = 1;
r2 = 0:1/spanB:1;
r2 = 1 - r2;

r(1:spanR+1) = 1;
r(spanR:end) = r2;

g(1:spanR+1) = g1;
g(spanR:end) = g2;

b(1:spanR+1) = b1;
b(spanR:end) = b2;

map(100:-1:1,:) = [r g b];

colormap(map);

% I don't plot the full range of values...

maxRFF = max(max(FF)) %quantile(FF(~isnan(FF)),.99)
minRFF = min(FF(FF>0.0192)) %quantile(FF(~isnan(FF)),.8)

maxRFB = max(FB(FB<-0.0192)) %quantile(FB(~isnan(FB)),.01)
minRFB = min(min(FB)) %quantile(FB(~isnan(FB)),.1)

FF(FF<minRFF) = nan;
FF(FF>maxRFF) = nan;
FB(FB<minRFB) = nan;
FB(FB>maxRFB) = nan;

hold on;

nstep = 1;

stepCFB = (maxRFB-minRFB)/nstep;
stepCFF = (maxRFF-minRFF)/nstep;

%[p1,p1] = contourf(FB,[minRFB:stepCFB:maxRFB minRFB:stepCFB:maxRFB]);
%[p2,p2] = contourf(FF,[minRFF:stepCFF:maxRFF minRFF:stepCFF:maxRFF]);

%[p1,p1] = contourf(lon,lat,FB,minRFB:stepCFB:maxRFB);
%[p2,p2] = contourf(lon,lat,FF,minRFF:stepCFF:maxRFF);

FT = FB;
FT(:,:) = NaN;

for i = 1:X2-X1
 for j = 1:Y2-Y1
  if (abs(FB(i,j)) > FF(i,j))
   FT(i,j) = FB(i,j);
  elseif (abs(FB(i,j)) < FF(i,j))
   FT(i,j) = FF(i,j);
  end
 end
end

%[p1,p1] = contourf(lon,lat,FT,5);
[p1,p1] = contourf(lon,lat,FF,5);
[p2,p2] = contourf(lon,lat,FB,5);


%set(p1,'LineStyle','none');
%set(p2,'LineStyle','none');

%caxis([minFB maxFF]);

caxis([-0.05 0.05]);


ylabel('Latitude','FontSize',18)
xlabel('Longitude','FontSize',18)
set(gca,'FontSize',16)
cb = colorbar;
set(cb, 'FontSize',16)
axis image

if arch == 1
 title(['FSLE, HR (',num2str(depth),'m)'], 'FontSize', 21)
 label = strcat('./plot/fsle_',num2str(depth),'_',season,'_',R,'_h.eps')
else
 title(['FSLE, LR (',num2str(depth),'m)'], 'FontSize', 21)
 label = strcat('./plot/fsle_',num2str(depth),'_',season,'_',R,'_l.eps')
end

print(ch,'-dpsc2',label);
close all;


end
end
end
end
