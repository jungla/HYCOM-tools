clear; close all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
tline=fgetl(gridbfid);
idm=sscanf(tline,'%f',1);
tline=fgetl(gridbfid);
jdm=sscanf(tline,'%f',1);

ijdm=idm*jdm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% field indices in the archv file minus 1 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);


lday = '';

N = '1';
k = str2num(N);

G = 'T';

X1 = 1;
X2 = idm;
Y1 = 1;
Y2 = jdm;

for arch = 1:1

for time  = 2:2

day   = textread('../../3D/archivesDay_2');
year  = textread('../../3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

if(arch == 1)
 file = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
else
 file = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
end

Tt = hycomread(file,idm,jdm,ijdm,10+k*5);


[ch] = figure;

maxT   = 30; %quantile(T(~isnan(T)),.95);
minT   = 0; %quantile(T(~isnan(T)),.05);

p1 = imagesc(tlon(1,:),tlat(:,1),Tt);
caxis([minT maxT]);
hold on

% plot box

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

 x1 = [tlon(1,X1) tlon(1,X2)];
 x2 = [tlon(1,X1) tlon(1,X1)];
 x3 = [tlon(1,X2) tlon(1,X2)];
 y1 = [tlat(Y1,1) tlat(Y1,1)];
 y2 = [tlat(Y2,1) tlat(Y2,1)];
 y3 = [tlat(Y1,1) tlat(Y2,1)];

 if (s == 1)
  line(x1,y1,'LineStyle','-','Color','k','LineWidth',1.2);
  line(x1,y2,'LineStyle','-','Color','k','LineWidth',1.2);
  line(x2,y3,'LineStyle','-','Color','k','LineWidth',1.2);
  line(x3,y3,'LineStyle','-','Color','k','LineWidth',1.2);
  text(tlon(1,X1)+0.5, tlat(Y1,1)+0.6, R,'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color','k');
 else
  if (R == 'As')
   line(x1,y1,'LineStyle','-','Color','k','LineWidth',1.2);
   line(x1,y2,'LineStyle','-','Color','k','LineWidth',1.2);
   line(x2,y3,'LineStyle','-','Color','k','LineWidth',1.2);
   line(x3,y3,'LineStyle','-','Color','k','LineWidth',1.2);
   text((tlon(1,X2)+tlon(1,X1))*0.5, (tlat(Y2,1)+tlat(Y1,1))*0.5,'S','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14,'Color','k');
  end
 end
 
 end % end region
end % end s_region



%set(0,'Units','normalized')
%[p1,p1] = contourf(lon,lat,T,50);
%set(p1,'LineStyle','none');
axis xy;
axis image;
set(gca,'FontSize',14)
set(gca,'FontSize',14)
%load('hycom_colormap','mycmap')
%set(ch,'Colormap',mycmap)
xlabel('Longitude','fontsize',18);
ylabel('Latitude','fontsize',18);

f=load('Jet2');
c1=f(:,1);c2=f(:,2);c3=f(:,3);
for i=1:size(c1),map(i,:) = [c1(i) c2(i) c3(i)];end
colormap(map);
cb = colorbar

set(gca,'FontSize',18)
%cb = colorbar;
set(cb, 'FontSize',18)

if(arch == 1)
label = strcat('./plot/',N,'/high-res/layerN_TSR_h_016_archv.',lyear,'_',lday,'_',N,'_',G,'_T_00.a.eps')
%title(['Temperature, layer ',N,', HR, day: ',lday,' year:',lyear]);
else
label = strcat('./plot/',N,'/low-res/layerN_TSR_l_016_archv.',lyear,'_',lday,'_',N,'_',G,'_T_00.a.eps')
%title(['Temperature, layer ',N,', LR, day: ',lday,' year:',lyear]);
end

saveas(ch,label,'psc2');

close all;


end
end
