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
%filet = '../../topo0.02/depth_GSa0.02_08.a';

%topo = hycomread(filet,idm,jdm,ijdm,1);

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

rmin = 33.0; % good values for 1m: 33.5 37.0
rmax = 35.0; % values for ml:         33.0 35.0

dmax = 20;  % depth

dayi = 1;    % variables for day loop
dayf = 366;  %
dstep = 1;   %

step = 4000;  % mesh # points

N = 30;      % total number of layers, don't touch this. just change the displayed depth

for region = 1:4

 if (region == 1)
  X1 = 472
  X2 = 839
  Y1 = 77
  Y2 = 267
  R = 'A'
 elseif (region == 2)
  X1 = 840
  X2 = 1279
  Y1 = 77
  Y2 = 267
  R = 'B'
 elseif (region == 3)
  X1 = 619
  X2 = 986
  Y1 = 774
  Y2 = 900
  R = 'C'
 else
  X1 = 472
  X2 = 766
  Y1 = 393
  Y2 = 584
  R = 'D'
 end


lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

for year=8:9
for day=1:366

if ((year ~= 8) || (day ~= 1))

for arch = 1:2

lday  = digit(day,3);
lyear = digit(year,4);

lday
lyear

for s = 1:1 % type of section

clear ZI trho tdepth rho depth

 if (arch == 1)
  file  = strcat('../../stratification/density_z/output/high-res/',R,'/density_s_h_016_archv.',lyear,'_',lday,'_',R,num2str(s),'s_00.dat');
  file1 = strcat('../../stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.',lyear,'_',lday,'_00.a');
  file2 = strcat('../../kinematics/output/dssv/high-res/vorticity_h_016_archv.',lyear,'_',lday,'_00.a');
  file3 = strcat('../../stratification/layerN_TSR/output/1/high-res/layerN_TSR_h_016_archv.',lyear,'_',lday,'_1_R_00.a');
 else
  file  = strcat('../../stratification/density_z/output/low-res/',R,'/density_s_l_016_archv.',lyear,'_',lday,'_',R,num2str(s),'s_00.dat');
  file1 = strcat('../../stratification/mixedlayer/output/low-res/mixlayer_l_016_archv.',lyear,'_',lday,'_00.a');
  file2 = strcat('../../kinematics/output/dssv/low-res/vorticity_l_016_archv.',lyear,'_',lday,'_00.a');
  file3 = strcat('../../stratification/layerN_TSR/output/1/low-res/layerN_TSR_l_016_archv.',lyear,'_',lday,'_1_R_00.a');
 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove nan and reshape matrix    %

 section = textread(file);
 tsize = size(section,1);
 section(abs(section) > 10^6) = NaN;
 section = reshape(section,tsize,4); 

 section(isnan(section(:,2)),3) = NaN;
 section(isnan(section(:,3)),2) = NaN;

% section(isnan(section(:,3)),:) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute ML, for each day, for each resolution %

 tml = hycomread(file1,idm,jdm,ijdm,1);
 tml = tml./9806;

if(s == 1)
  mld = tml(round((Y1+Y2)/2),X1:X2);
else
  mld = tml(Y1:Y2,round((X1+X2)/2));
end
 %mld = avg_region(tml,tpscx,tpscy,X1,X2,Y1,Y2,s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute vort, for each day, for each resolution %

 tvort = hycomread(file2,idm,jdm,ijdm,1);
 tvort = tvort./(8*10^-5);
 vort = tvort(Y1:Y2,X1:X2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute density, for each day, for each resolution %

 tdens = hycomread(file3,idm,jdm,ijdm,1);
 dens = tdens(Y1:Y2,X1:X2);


%%%%%%%%%%%%
% plotting %

 ch = figure('PaperPosition', [0 0 1 1],'PaperUnits','normalized');

 ids = X2-X1+1;
 jds = Y2-Y1+1;

 if (s == 1)
  fd = ids*N;
  x = lon;
  xds = ids;
 else
  fd = jds*N;
  x = lat;
  xds = jds;
 end

%%%%%%%%%%%%%%%%%%%%%%%
% INTERPOLATIONS      %

 minX = min(section(1:fd,4));
 maxX = max(section(1:fd,4));
 minY = min(section(1:fd,2));
 maxY = max(section(1:fd,2));

 YI = minY:(maxY-minY)/step:maxY;

 %%%%%%%%%%%%%%%%%%%%%%%
 % MESH INTERPOLATED   %

% YI = YI';
% X  = section(1:fd,4);
% Y  = section(1:fd,2);
% ZI = griddata(X,Y,section(1:fd,3),XI,YI,'cubic');


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Z-LINEAR INTERPOLATED Option %

 % transform matrix section in 2 matrix with depth and density

 tdepth = zeros(xds,N);
 trho   = zeros(xds,N);
 ZI     = zeros(xds,step+1);

 for i = 1:xds
  for n = 1:N
  tdepth(i,n) = section(i+(n-1)*xds,2);
  trho(i,n)   = section(i+(n-1)*xds,3);
  end
 end


 
 ZI = nan(xds,step+1);

 for i = 1:xds
  depth = zeros(sum(~isnan(trho(i,:))),1);
  rho   = zeros(sum(~isnan(trho(i,:))),1);

  depth(:) = tdepth(i,~isnan(trho(i,:)));
  rho(:)   = trho(i,~isnan(trho(i,:)));

%%% check if values are deeper than depth...

%  if(s == 1)
%   depth(depth > topo(i,round((X1+X2)/2))) = NaN;
%  else
%   depth(depth > topo(round((Y1+Y2)/2),i)) = NaN;
%  end

%  depth = depth(~isnan(depth));
%  rho   = rho(~isnan(depth));


%%% the interpolation doesn't like repeted values... I may have some

  j = 1;

  for n =2:length(depth);
   if(depth(n) <= depth(n-1))
    depth(n) = depth(n) + 0.001*j;
    j = j + 1;
   end
  end

  tZI = interp1(depth(:),rho(:),YI,'cubic');

%  if(s == 1)
%  tZI(YI > topo(i,round((X1+X2)/2))) = NaN;
%  else
%  tZI(YI > topo(round((Y1+Y2)/2),i)) = NaN;
%  end

  ZI(i,:) = tZI;        % interpolated density profile
 end

Ymax = find(YI < dmax);
YmaxI = Ymax(end);

ZI = ZI(:,1:YmaxI);
YI = YI(1:YmaxI);

ZI = ZI';

%rmin = min(min(ZI))
%rmax = max(max(ZI))

 rmin = min(min(ZI))
 rmax = 33.5

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NON-INTERPOLATED Option %

% axes( 'Position',[.005 .005 .99 .99],'xtick',[],'ytick',[],'box','on','handlevisibility','off')
 s0 = subplot(3,1,1)%,'Position',[0.2 0.5 0.6 0.3]),
 imagesc(lon,lat,vort);
 axis xy;
 colorbar;
 caxis([-1 2])
 ylabel('Latitude');

 if (s == 1)
  line([lon(1) lon(end)],[(lat(1)+lat(end))/2 (lat(1)+lat(end))/2],'Color', 'k');
 else
  line([(lon(1)+lon(end))/2 (lon(1)+lon(end))/2],[lat(1) lat(end)],'Color', 'k');
 end

 s1 = subplot(3,1,2)%,'Position',[0.2 0.1 0.6 0.3]),
 imagesc(lon,lat,dens);
 axis xy;
 ylabel('Latitude');
 caxis([quantile(dens(~isnan(dens)),0.1) quantile(dens(~isnan(dens)),0.9)]);
 colorbar;
 if (s == 1)
  line([lon(1) lon(end)],[(lat(1)+lat(end))/2 (lat(1)+lat(end))/2],'Color', 'k');
 else
  line([(lon(1)+lon(end))/2 (lon(1)+lon(end))/2],[lat(1) lat(end)],'Color', 'k');
 end


 s1 = subplot(3,1,3)%,'Position',[0.2 0.1 0.6 0.3]),
 p1 = imagesc(lon,YI,ZI);
% [p1,p1] = contourf(lon,YI,ZI,50);
% set(p1,'edgecolor','none');
 hold on;
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')
 plot(x,mld,'k');
 ylabel('Depth (m)');
 xlabel('Longitude');
 hold off;
 colorbar;
% caxis([rmin rmax]);
% ylim([0 dmax]);

if (arch == 1)
 label = strcat('./plot/',num2str(dmax),'/high-res/vort_dens_',num2str(dmax),'_',lyear,'_',lday,'_h_',R,num2str(s),'s.eps')
% title(strcat(['Density section and Vorticity field of region ',R,' high-res. Year ',lyear,', day ',lday]));
else
 label = strcat('./plot/',num2str(dmax),'/low-res/vort_dens_',num2str(dmax),'_',lyear,'_',lday,'_l_',R,num2str(s),'s.eps')
% title(strcat(['Density section and Vorticity field of region ',R,' low-res. Year ',lyear,', day ',lday]));
end


 print(ch,'-dpsc2',label);

close all;

end % end section
end % end arch
end % end day
end % end day
end % end day
end % end region
