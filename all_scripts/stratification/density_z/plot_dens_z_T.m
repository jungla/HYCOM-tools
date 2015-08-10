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
filet = '../../topo0.02/depth_GSa0.02_08.a';

ttopo = hycomread(filet,idm,jdm,ijdm,1);

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

%rmin = 33.7; % good values for 1m: 33.5 37.0
%rmax = 34.7; % values for ml:         33.0 35.0

dmax = 400;  % depth (m)
step = 4000;  % mesh # points

N = 30;      % total number of layers, don't touch this. just change the displayed depth

for region = 1:1

[X1,X2,Y1,Y2,R] = regions(region);

topo = ttopo(Y1:Y2,X1:X2);
lat = tlat(Y1:Y2,1);
lon = tlon(1,X1:X2);

day   = textread('../../3D/archivesDay_all');
year  = textread('../../3D/archivesYear_all');

s = 1;  % type of section

for time    = 2:2

if (time == 1)
 daym = 199; % d 200 y 8
else
 daym = 400; % d 35  y 9 
end

lti = -15;
lts = +15;

for arch = 1:1

for sectid  = 1:2

TZI = 0;
tmld = 0;

for t = lti:1:lts

R
lday   = digit(day(daym+t),3)
lyear  = digit(year(daym+t),4)
liday  = digit(day(daym),3);
liyear = digit(year(daym),3);


%%%%%% 2 sections per map
if time == 1
 if sectid ==1
  l1 = 32.75;
 else
  l1 = 32.7;
 end
else
 if sectid ==1
  l1 = 32.1;
 else
  l1 = 32.6;
 end
end

 l1id = find(tlat(:,1) > l1,1);

arch
lday
lyear

clear ZI trho tdepth rho depth

 if (arch == 1)
  file  = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
  file1 = strcat('../../stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.',lyear,'_',lday,'_00.a');
 else
  file  = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
  file1 = strcat('../../stratification/mixedlayer/output/low-res/mixlayer_l_016_archv.',lyear,'_',lday,'_00.a');
 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove nan and reshape matrix    %

 section = section_rho_x(idm,jdm,X1,X2,l1id,30,file,tlon);
 tsize = size(section,1);
 section(abs(section) > 10^6) = NaN;
 section = reshape(section,tsize,4); 

% section(isnan(section(:,2)),3) = NaN;
% section(isnan(section(:,3)),2) = NaN;

% section(isnan(section(:,3)),:) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute ML, for each day, for each resolution %

 tml = hycomread(file,idm,jdm,ijdm,6);
 tml = tml./9806;

if(s == 1)
 mld = tml(l1id,X1:X2);
else
 mld = tml(Y1:Y2,l1id);
end
 tmld = tmld + mld;
 %mld = avg_region(tml,tpscx,tpscy,X1,X2,Y1,Y2,s);

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
 minY = 0.0; %min(section(1:fd,2));
 maxY = 4000; %max(section(1:fd,2));

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
%   depth(depth > topo(l1id,i)) = NaN;
%  else
%   depth(depth > topo(i,l1id)) = NaN;
%  end

  depth = depth(~isnan(depth));
  rho   = rho(~isnan(depth));

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
%  tZI(YI > topo(l1id,i)) = NaN;
%  end

  ZI(i,:) = tZI;        % interpolated density profile
 end % read density


Ymax = find(YI < dmax);
YmaxI = Ymax(end);

ZI = ZI(:,1:YmaxI);
YI = YI(1:YmaxI);

ZI = ZI';

%rmin = min(min(ZI))
%rmax = max(max(ZI))

TZI = TZI + ZI;
t
end % time loop

TZI = TZI./(lts-lti+1);
tmld = tmld./(lts-lti+1);

mTZI  = mean(TZI,2);
sTZI  = std(TZI,1,2);
mtmld = mean(tmld,2);
stmld = std(tmld,1,2);

if time == 1
 rmin = 31.4
 rmax = 35   %34.55
else
 rmin = 31.4 %33.5
 rmax = 35
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% p1 = imagesc(lon,YI,ZI);
 p1 = plot(mTZI,'Color',[0.5 0.5 0.5],'LineWidth',2);
 hold on;
 p2 = plot(mTZI+sTZI,'Color',[0.5 0.5 0.5],'LineWidth',1,'LineStyle','--');
 p3 = plot(mTZI-sTZI,'Color',[0.5 0.5 0.5],'LineWidth',1,'LineStyle','--');
 view(-90,90)

 line([mtmld mtmld],[rmin rmax],'Color','k','LineWidth',2);
 line([mtmld+stmld mtmld+stmld],[rmin rmax],'Color','k','LineWidth',1,'LineStyle','--');
 line([mtmld-stmld mtmld-stmld],[rmin rmax],'Color','k','LineWidth',1,'LineStyle','--');
% scatter(section(1:fd,4),section(1:fd,2),section(1:fd,3),'k','.')
% plot(x,tmld,'Color','white','LineWidth',2);
 xlabel('Depth (m)','FontSize',21);
 ylabel('Density','FontSize',21);
 set(gca,'FontSize',21)
% axis ij;
 set(gca,'XDir','reverse');
 set(gca,'YDir','reverse');
 hold off;

 if time == 2
  tlabel = 'average over A-A''';
 else
  tlabel = 'average over B-B''';
 end

 tlabel = strcat(num2str(l1),'N');

 title({'\rho';tlabel},'FontSize',21)

 xlim([0 dmax]);
 ylim([rmin rmax]);


if (arch == 1)
 label = strcat('./plot/',num2str(dmax),'/high-res/dens_z_',num2str(dmax),'_',liyear,'_',liday,'_h_',R,'_',num2str(l1),'.eps')
else
 label = strcat('./plot/',num2str(dmax),'/low-res/dens_z_',num2str(dmax),'_',liyear,'_',liday,'_l_',R,'_',num2str(l1),'.eps')
end


 print(ch,'-dpsc2',label);

close all;

end % end arch
end % end day
end % end section
end % end region
