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

filee = strcat('../../GSa0.02/expt_01.6/data/forcing.tauewd.a');
filen = strcat('../../GSa0.02/expt_01.6/data/forcing.taunwd.a');

day   = textread('../archivesDay_all');
year  = textread('../archivesYear_all');

dayi  = 1;
dayf  = 498;
dstep = 1;

for region = 5:5

 [X1,X2,Y1,Y2,G] = regions(region);

ftch = figure;
fsch = figure;
fcch = figure;

for arch = 1:1

for did =1:1

 depth = readline('../3D/layersDepth_4',did);
 depthid = str2num(readline('../3D/layersDepthID_4',did));
 depth

 itime = 0;

clear fcC fsC ftC

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
 idtime = 4*day(time) + hour;
 
 ttx = hycomread(filee,idm,jdm,ijdm,idtime);
 tty = hycomread(filen,idm,jdm,ijdm,idtime);

% land = landt(Y1:Y2,X1:X2);

 tx = ttx(Y1:Y2,X1:X2);
 ty = tty(Y1:Y2,X1:X2);
 R  = Rt(Y1:Y2,X1:X2);
 fs = fluxs(Y1:Y2,X1:X2);
 ft = fluxt(Y1:Y2,X1:X2);
 C = curl(tx,ty);

 R  = smooth2(R,2);

 ids = X2-X1+1;
 jds = Y2-Y1+1;
 
 R  = reshape(R,ids*jds,1);
 C  = reshape(C,ids*jds,1);
 fs = reshape(fs,ids*jds,1);
 ft = reshape(ft,ids*jds,1);

r = nancov(R,C)
 fcC(itime) = r(1,2);
r = nancov(R,fs)
 fsC(itime) = r(1,2);
r = nancov(R,ft)
 ftC(itime) = r(1,2);

% numer of bins

end % end loop days

windowSize = 30;

ftC = filter(ones(1,windowSize)/windowSize,1,ftC);
fsC = filter(ones(1,windowSize)/windowSize,1,fsC);
fcC = filter(ones(1,windowSize)/windowSize,1,fcC);


%%%%%%%%%%%%% c
figure(fcch);
p1 = plot(dayi:dayf,fcC)
set(p1,'LineWidth',0.7);
hold on

if(arch == 1)
set(p1,'Color','k')
else
set(p1,'Color','b')
end

if(did == 1)
set(p1,'Marker','+')
elseif(did == 2)
set(p1,'Marker','*')
elseif(did == 3)
set(p1,'Marker','o')
else
set(p1,'Marker','x')
end

ylabel('cov','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:30:itime);
set(gca,'XTickLabel',timeBar(1:30:end))


%%%%%%%%%%% s

figure(fsch);
p1 = plot(dayi:dayf,fsC)
set(p1,'LineWidth',0.7);
hold on

if(arch == 1)
set(p1,'Color','k')
else
set(p1,'Color','b')
end

if(did == 1)
set(p1,'Marker','+')
elseif(did == 2)
set(p1,'Marker','*')
elseif(did == 3)
set(p1,'Marker','o')
else
set(p1,'Marker','x')
end

ylabel('cov','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:30:itime);
set(gca,'XTickLabel',timeBar(1:30:end))


%%%%%%%%%% t

figure(ftch);
p1 = plot(dayi:dayf,ftC)
set(p1,'LineWidth',0.7);
hold on

if(arch == 1)
set(p1,'Color','k')
else
set(p1,'Color','b')
end

if(did == 1)
set(p1,'Marker','+')
elseif(did == 2)
set(p1,'Marker','*')
elseif(did == 3)
set(p1,'Marker','o')
else
set(p1,'Marker','x')
end

ylabel('cov','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:30:itime);
set(gca,'XTickLabel',timeBar(1:30:end))


%end
end
end

fileos = strcat('./plot/trend_cov_sd_',G,'.eps');
fileot = strcat('./plot/trend_cov_td_',G,'.eps');
fileoc = strcat('./plot/trend_cov_wcurld_',G,'.eps');

print(ftch,'-dpsc2',fileot)
print(fcch,'-dpsc2',fileoc)
print(fsch,'-dpsc2',fileos)

close all;

end
