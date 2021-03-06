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

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);


filen = strcat('../../GSa0.02/expt_01.6/data/forcing.wndspd.a');

day   = textread('../archivesDay_all');
year  = textread('../archivesYear_all');

dayi  = 498-365;
dayf  = 498;
dstep = 1;

ftsuh = figure;

for region = 5:5

[X1,X2,Y1,Y2,G] = regions(region);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

for arch = 1:1

for did =1:1

 depth = readline('../3D/layersDepth_4',did);
 depthid = str2num(readline('../3D/layersDepthID_4',did));
 depth

 itime = 0;

clear frC fuC fsC ftC

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
 day(time);
 idtime = 4*day(time) + hour;
 
 ut = hycomread(filen,idm,jdm,ijdm,idtime);

% land = landt(Y1:Y2,X1:X2);

 R  = Rt(Y1:Y2,X1:X2);

 ids = X2-X1+1;
 jds = Y2-Y1+1;
 
 fuC(itime) = avg_region(ut,tpscx,tpscy,X1,X2,Y1,Y2,0);
 fsC(itime) = avg_region(fluxs,tpscx,tpscy,X1,X2,Y1,Y2,0);
 ftC(itime) = avg_region(fluxt,tpscx,tpscy,X1,X2,Y1,Y2,0);
 frC(itime) = avg_region(R,pscx,pscy,1,ids,1,jds,0);

% numer of bins

end % end loop days

% correlation

temp1 = zeros(itime,1);
temp2 = zeros(itime,1);
temp3 = zeros(itime,1);

for day = 1:itime

temp1(1:end-day+1) = frC(day:end);
temp1(end-day+1:end) = frC(1:day);

r = corrcoef(fuC(:),temp1,'rows','pairwise');
fuCm(day) = r(1,2);
r = corrcoef(fsC(:),temp1,'rows','pairwise');
fsCm(day) = r(1,2);
r = corrcoef(ftC(:),temp1,'rows','pairwise');
ftCm(day) = r(1,2);
r = corrcoef(frC(:),temp1,'rows','pairwise');
faCm(day) = r(1,2);

end % end correlation loop



end
end
end



%%%%%%%%%%%%% t,s,u
figure(ftsuh);
p1 = plot(1:itime,ftCm,'--k',1:itime,fsCm,'-.k',1:itime,fuCm,':k',1:itime,faCm,'-r')
set(p1,'LineWidth',1.5);
hleg1 = legend('f_T','f_S','u^*','\rho_{10}');
set(hleg1,'Location','NorthEast','FontSize',14)

%end

ylabel('r','FontSize',18)
xlabel('Time Lag (days)','FontSize',18)

set(gca,'XTick', 0:30:itime);
set(gca,'XTickLabel',0:30:itime,'FontSize',15);
ylim([-1 +1]);
xlim([0 itime])

fileostu = strcat('./plot/trend_corr_dens_time_',G,'.eps')

print(ftsuh,'-dpsc2',fileostu)

close all;

