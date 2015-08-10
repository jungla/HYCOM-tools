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
file1 = '../topo0.02/depth_GSa0.02_08.a';

lont = hycomread(file,idm,jdm,ijdm,1);
latt = hycomread(file,idm,jdm,ijdm,2);
tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

lday = '';

filee = strcat('../../GSa0.02/expt_01.6/data/forcing.tauewd.a');
filen = strcat('../../GSa0.02/expt_01.6/data/forcing.taunwd.a');

time = 0;

% define topography

tml = hycomread(file1,idm,jdm,ijdm,1);

landt = zeros(jdm,idm);
landt = 20.0;

for i = 1:idm
   for j = 1:jdm
        if(isnan(tml(j,i)))
        landt(j,i) = 0;
        else
        landt(j,i) = 20;
        end
    end
end


for day  = 36:36
for hour = 1:4

time = time + 1;

lday  = digit(day,3);
lhour = digit(hour,4);

ut = hycomread(filee,idm,jdm,ijdm,time);
vt = hycomread(filen,idm,jdm,ijdm,time);

%if (hour == 4 && mod(day,1) == 0)

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;

lon = lont(1,X1:X2);
lat = latt(Y1:Y2,1);
pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

land = landt(Y1:Y2,X1:X2);

u = ut(Y1:Y2,X1:X2);
v = vt(Y1:Y2,X1:X2);

%maxwind = max(max(str(:,:)));

'plotting...'
fileo = strcat('./plot/forcing.wndstr_',lday,'_',lhour,'_',R,'.eps')

[ch] = figure;
%[c,c] = contourf(lon,lat,sqrt(u.^2 + v.^2),10);
%        set(c,'Color',[0.5 0.5 0.5]);
%colorbar;
hold on
%l = contour(lon,lat,land);
%hold on

stp = 10;

'taue', avg_region(u,pscx,pscy,1,ids,1,jds,0)
'taun', avg_region(v,pscx,pscy,1,ids,1,jds,0)

u = u(1:stp:end,1:stp:end);
v = v(1:stp:end,1:stp:end);
lon = lon(1:stp:end,1:stp:end);
lat = lat(1:stp:end,1:stp:end);

q = quiver(lon,lat,u,v);
axis image;
axis xy;

title(['Wind stress, day ',lday, ', hour ', num2str(hour*6)]);
%colormap('hot');
%caxis([-1 1])

'saving...'

print(ch,'-dpsc2',fileo)

close all;
%end

end
end
end
