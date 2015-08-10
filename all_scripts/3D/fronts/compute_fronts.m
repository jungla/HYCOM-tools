clear; close all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% field indices in the archv file minus 1 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

day   = textread('../archivesDay_2');
year  = textread('../archivesYear_2');

for region = 1:1

 [X1,X2,Y1,Y2,G] = regions(region);

 lon = tlon(1,X1:X2);
 lat = tlat(Y1:Y2,1);

for time  = 1:2
 time
 lday  = digit(day(time),3);
 lyear = digit(year(time),4);

for did = 1:1
 depth = readline('../layersDepth_4',did);
 depthid = str2num(readline('../layersDepthID_4',did));
 depth

for arch = 1:1

clear FTt wTt

n = 0;
FT = 0;
wT = 0;
lti = -3;
lts = 4;

 if(arch == 1)
  filer = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zr.A');
  filef = strcat('../qvector/output/high-res/F_h_016_archv.',lyear,'_',lday,'_00.a');
  filew = strcat('../../../GSa0.02_3D/016_archv.',lyear,'_',lday,'_00_3zw.A');
 else
  filer = strcat('../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zr.A');
  filef = strcat('../qvector/output/low-res/F_l_016_archv.',lyear,'_',lday,'_00.a');
  filew = strcat('../../../GSa0.08_3D/archv.',lyear,'_',lday,'_00_3zw.A');
 end
 
 Rt = binaryread(filer,idm,jdm,ijdm,depthid);
 wt = binaryread(filew,idm,jdm,ijdm,depthid);
 Ft = binaryread(filef,idm,jdm,ijdm,depthid);


% land = landt(Y1:Y2,X1:X2);

 R  = Rt(Y1:Y2,X1:X2);
 w  = wt(Y1:Y2,X1:X2);
 F  = Ft(Y1:Y2,X1:X2);

 R = smooth2(R,2);
 [grx,gry] = gradient(R);
 c = sqrt(grx.^2 + gry.^2);

 ids = X2-X1+1;
 jds = Y2-Y1+1;

 d = nan(jds,ids);

% regions size

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

'plotting...'

if (arch==1)
 fileor = strcat('./plot/high-res/fronts_r_h_',lyear,'_',lday,'_',depth,'_',G,'.eps')
else
 fileor = strcat('./plot/low-res/fronts_r_l_',lyear,'_',lday,'_',depth,'_',G,'.eps')
end

%%%%%%%%%%%%% d

[ch] = figure;
delta = 0.02;

length(find(abs(d)>delta))/length(find(~isnan(d)))
%d(abs(d<delta)) = NaN;

imagesc(lon,lat,d);
hold on;
%[r,r] = contour(lon,lat,abs(c),[2*10^-4 2*10^-4]);
[r0,r0] = contour(lon,lat,d,[ delta  delta]);
[r1,r1] = contour(lon,lat,d,[-delta -delta]);
%set(r, 'Color',[0 0 0],'LineStyle','-','ShowText','off','LineWidth',1);
set(r0,'Color',[0 0 0],'LineStyle','-','ShowText','off');
set(r1,'Color',[0 0 0],'LineStyle',':','ShowText','off');


axis xy;
axis image;
colorbar;

title('\delta','FontSize',18)
'saving...'
ylabel('','FontSize',18)
xlabel('','FontSize',18)
print(ch,'-dpsc2',fileor)

end
end
end
end
