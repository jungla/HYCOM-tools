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

filen = strcat('../../GSa0.02/expt_01.6/data/forcing.wndspd.a');

day   = textread('../archivesDay_all');
year  = textread('../archivesYear_all');

dayi  = 1;
dayf  = 498;
dstep = 1;

ftsuh = figure;

for region = 6:-1:5

 [X1,X2,Y1,Y2,G] = regions(region);


for arch = 1:1

for did =1:1

 depth = readline('../3D/layersDepth_4',did);
 depthid = str2num(readline('../3D/layersDepthID_4',did));
 depth

 itime = 0;

clear fuC fsC ftC

for time  = dayi:dstep:dayf

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1

% x bar for plotting
timeBar(itime) = day(time);

 if(arch == 1)
  filer = strcat('../../GSa0.02_3Da/016_archv.',lyear,'_',lday,'_00_3zr.A');
  file  = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
 else
  filer = strcat('../../GSa0.08_3Da/archv.',lyear,'_',lday,'_00_3zr.A');
  file  = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
 end


 fluxs  = hycomread(file,idm,jdm,ijdm,3);
 fluxt  = hycomread(file,idm,jdm,ijdm,4);
 
 Rt = binaryread(filer,idm,jdm,ijdm,did);

 hour   = 0; % archive is 00
 day(time)
 idtime = 4*day(time) + hour
 
 ut = hycomread(filen,idm,jdm,ijdm,idtime);

% land = landt(Y1:Y2,X1:X2);

 u = ut(Y1:Y2,X1:X2);
 R  = Rt(Y1:Y2,X1:X2);
 fs = fluxs(Y1:Y2,X1:X2);
 ft = fluxt(Y1:Y2,X1:X2);

 R  = smooth2(R,2);

 ids = X2-X1+1;
 jds = Y2-Y1+1;
 
 R  = reshape(R,ids*jds,1);
 u  = reshape(u,ids*jds,1);
 fs = reshape(fs,ids*jds,1);
 ft = reshape(ft,ids*jds,1);

r = corrcoef(R,u,'rows','pairwise')
 fuC(itime) = r(1,2);
r = corrcoef(R,fs,'rows','pairwise')
 fsC(itime) = r(1,2);
r = corrcoef(R,ft,'rows','pairwise')
 ftC(itime) = r(1,2);

% numer of bins

end % end loop days

% filter: moving average

%windowSize = 30;

%ftC = filter(ones(1,windowSize)/windowSize,1,ftC);
%fsC = filter(ones(1,windowSize)/windowSize,1,fsC);
%fcC = filter(ones(1,windowSize)/windowSize,1,fcC);
%fuC = filter(ones(1,windowSize)/windowSize,1,fuC);

% montlhy mean
for m = 1:ceil(itime/30)
im = m*30-15;
fm = m*30+15;
 if (fm > length(ftC))
  fm = length(ftC);
 end

 ftCm(m) = sum(ftC(im:fm))/length(im:fm);
 fsCm(m) = sum(fsC(im:fm))/length(im:fm);
 fuCm(m) = sum(fuC(im:fm))/length(im:fm);
end


%%%%%%%%%%%%% t,s,u
figure(ftsuh);
p1 = plot(ftCm)
set(p1,'LineWidth',0.7,'Color','k');
hold on
p2 = plot(fsCm)
set(p2,'LineWidth',0.7,'Color','k');
hold on
p3 = plot(fuCm)
set(p3,'LineWidth',0.7,'Color','k');

set(p1,'Marker','+')
set(p2,'Marker','*')
set(p3,'Marker','o')

if (region == 6)
set(p1,'LineStyle',':')
set(p2,'LineStyle',':')
set(p3,'LineStyle',':')
end

%end
end
end
end

ylabel('r','FontSize',18)
xlabel('Time','FontSize',18)

set(gca,'XTick', 1:ceil(itime/30));
set(gca,'XTickLabel',{'JAN';'FEB';'MAR';'APR';'MAY';'JUN';'JUL';'AUG';'SEP';'OCT';'NOV';'DEC'})

fileostu = strcat('./plot/trend_corr_dens_',G,'.eps');

print(ftsuh,'-dpsc2',fileostu)

close all;

