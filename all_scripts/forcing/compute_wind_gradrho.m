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

filee = strcat('../../GSa0.02/expt_01.6/data/forcing.tauewd.a');
filen = strcat('../../GSa0.02/expt_01.6/data/forcing.taunwd.a');

day   = textread('../3D/archivesDay');
year  = textread('../3D/archivesYear');

for region = 5:5

 [X1,X2,Y1,Y2,G] = regions(region);

 lon = tlon(1,X1:X2);
 lat = tlat(Y1:Y2,1);

for did =1:1
 depth = readline('../3D/layersDepth_4',did);
 depthid = str2num(readline('../3D/layersDepthID_4',did));
 depth

for arch = 1:1

Ff = figure()
wf = figure()

for time  = 8:9
 time
 lday  = digit(day(time),3);
 lyear = digit(year(time),4);

 if (time == 8)
  daym = 20; % d 200 y 8
 else
  daym = 40; % d 35  y 9 
 end


clear FTt wTt FT wT

n = 0;
FT = 0;
wT = 0;
lti = -3;
lts = 4;

for t = lti:1:lts

lday   = digit(day(daym+t),3)
lyear  = digit(year(daym+t),4)
liday  = digit(day(daym),3);
liyear = digit(time,3);

 if(arch == 1)
  filer = strcat('../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
  filef = strcat('../3D/qvector/output/high-res/F_h_016_archv.',lyear,'_',lday,'_00.a');
  filew = strcat('../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zw.A');
 else
  filer = strcat('../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
  filef = strcat('../3D/qvector/output/low-res/F_l_016_archv.',lyear,'_',lday,'_00.a');
  filew = strcat('../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zw.A');
 end
 
 Rt = binaryread(filer,idm,jdm,ijdm,depthid);
 wt = binaryread(filew,idm,jdm,ijdm,depthid);
 Ft = binaryread(filef,idm,jdm,ijdm,depthid);

 hour   = 1 % archive is 00
 idtime = 4*day(daym+t) + hour;
 
 ttx = hycomread(filee,idm,jdm,ijdm,idtime);
 tty = hycomread(filen,idm,jdm,ijdm,idtime);

% land = landt(Y1:Y2,X1:X2);

 tx = ttx(Y1:Y2,X1:X2);
 ty = tty(Y1:Y2,X1:X2);
 R  = Rt(Y1:Y2,X1:X2);
 w  = wt(Y1:Y2,X1:X2);
 F  = Ft(Y1:Y2,X1:X2);

 R = smooth2(R,2);

% define fronts

 [rx,ry] = gradient(R);
 c = sqrt(rx.^2 + ry.^2);

 ids = X2-X1+1;
 jds = Y2-Y1+1;

 d = nan(jds,ids);

% regions size
 delta = 0.02;
 n = 2;

for i = 1+n:ids-n
 for j = 1+n:jds-n
 maxr = max(max((R(j-n:j+n,i-n:i+n))));
 minr = min(min((R(j-n:j+n,i-n:i+n))));
 if (~isempty(maxr) & ~isempty(minr))
  d(j,i) = 2*R(j,i) - maxr - minr;
 end
 end
end

 trx = -rx;
 rx =  ry;
 ry =  trx;

 a = asin(ry./sqrt(rx.^2 + ry.^2));
 a(rx<=0) = pi - a(rx<=0);
 a(rx>0 & a<0) =  2*pi + a(rx>0 & a<0);

 b = asin(ty./sqrt(tx.^2 + ty.^2));
 b(tx<=0 ) = pi - b(tx<=0);
 b(tx>0 & b<0) =  2*pi + b(tx>0 & b<0);

 O = a-b;
 O(O < -pi) = O(O < -pi) + 2*pi;
 O(O >  pi) = O(O >  pi) - 2*pi;

 O(isnan(a) | isnan(b)) = NaN;

 % retain only frontal regions
 length(find(abs(d)>delta))/length(find(~isnan(d)))*100
 O(d<delta) = NaN; % heavy side only (positive delta)

% Capet
% a  = sign(-ty.*rx + tx.*ry);
% b  = tx.*rx + ty.*ry;
% mb = sqrt(tx.^2 + ty.^2).*sqrt(rx.^2 + ry.^2);
% O  = -a.*acos(b./mb) + a.*pi*(0.5) + sign(tx.*rx).*0.5*pi;

 Ov = reshape(O,ids*jds,1);
 Fv = reshape(F,ids*jds,1);
 wv = reshape(w,ids*jds,1);

% Fv = log(abs(Fv));

% numer of bins
 bins = 100;

for i=1:2*bins
 FTt(i) = nanmean(Fv((i-1)*pi/bins-pi < Ov & Ov <= (i)*pi/bins-pi));
 wTt(i) = nanmean(wv((i-1)*pi/bins-pi < Ov & Ov <= (i)*pi/bins-pi));
end

 FT = FT + FTt;
 wT = wT + wTt;
 sum(isnan(FT))
 n = n+1;

end % end inner loop days

 FT = FT./n;
 wT = wT./n;

% smooth
% FT = smooth2(FT,5);
% wT = smooth2(wT,5);


'plotting...'
if (arch==1)
 fileof = strcat('./plot/tau_F_h_',depth,'_',G,'.eps')
 fileow = strcat('./plot/tau_w_h_',depth,'_',G,'.eps')
 fileoo = strcat('./plot/tau_O_h_',liyear,'_',liday,'_',depth,'_',G,'.eps')
else
 fileof = strcat('./plot/tau_F_l_',depth,'_',G,'.eps')
 fileow = strcat('./plot/tau_w_l_',depth,'_',G,'.eps')
 fileoo = strcat('./plot/tau_O_l_',liyear,'_',liday,'_',depth,'_',G,'.eps')
end

%%%%%%%%%%%%% O


[ch] = figure;
stp = 10;

hold on;

imagesc(lon,lat,R);
axis xy;
axis image;
colorbar;

u = tx(1:stp:end,1:stp:end);
v = ty(1:stp:end,1:stp:end);
lons = lon(1:stp:end,1:stp:end);
lats = lat(1:stp:end,1:stp:end);
q = quiver(lons,lats,u,v);

rxs = rx(1:stp:end,1:stp:end);
rys = ry(1:stp:end,1:stp:end);
qr = quiver(lons,lats,rxs,rys,3,'k');

caxis([min(min(R)) max(max(R))]);
%contour(lon,lat,O);
print(ch,'-dpsc2',fileoo)

%%%%%%%%%%% F

figure(Ff);
hold on;
x = -pi:pi/bins:pi-pi/bins;

if (time == 9)
 p = plot(x,FT,'k-','LineWidth',1.5);
else
 p = plot(x,FT,'k--','LineWidth',1.5);
end

%q = polyfit(x,FT,5);
%refcurve(q)
title('F','FontSize',24)
xlim([-pi pi])
'saving...'
%ylabel('','FontSize',18)
xlabel('\pi','FontSize',18)

set(gca,'XTick', [-pi -pi/2 0 pi/2 pi]);
set(gca,'XTickLabel',{'-1','-1/2','0','1/2','1'},'FontSize',15)


%%%%%%%%%% w

figure(wf);
hold on;
x = -pi:pi/bins:pi-pi/bins;

if (time == 9)
 p = plot(x,wT,'k-','LineWidth',1.5);
else
 p = plot(x,wT,'k--','LineWidth',1.5);
end

%q = polyfit(x,wT,5);
%refcurve(q)

title('w','FontSize',24)
xlim([-pi pi])
'saving...'
%ylabel('','FontSize',18)
xlabel('','FontSize',18)

set(gca,'XTick', [-pi -pi/2 0 pi/2 pi]);
set(gca,'XTickLabel',{'-1','-1/2','0','1/2','1'},'FontSize',15)

'saving...'

end % plot both seasons on the same frame

print(wf,'-dpsc2',fileow)
print(Ff,'-dpsc2',fileof)

end
close all;
end
end
