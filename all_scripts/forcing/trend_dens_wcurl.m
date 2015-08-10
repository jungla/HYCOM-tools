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

fcch = figure;

for arch = 1:2

for did =1:4

 depth = readline('../3D/layersDepth_4',did);
 depthid = str2num(readline('../3D/layersDepthID_4',did));
 depth

 itime = 0;

clear fcC

for time  = dayi:dstep:dayf

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1

% x bar for plotting
timeBar(itime) = day(time);

 if(arch == 1)
  filer = strcat('../../GSa0.02_3Da/016_archv.',lyear,'_',lday,'_00_3zr.A');
 else
  filer = strcat('../../GSa0.08_3Da/archv.',lyear,'_',lday,'_00_3zr.A');
 end

 Rt = binaryread(filer,idm,jdm,ijdm,did);

 hour   = 0; % archive is 00
 idtime = 4*day(time) + hour;
 
 ttx = hycomread(filee,idm,jdm,ijdm,idtime);
 tty = hycomread(filen,idm,jdm,ijdm,idtime);

% land = landt(Y1:Y2,X1:X2);

 tx = ttx(Y1:Y2,X1:X2);
 ty = tty(Y1:Y2,X1:X2);

 C = curl(tx,ty);

 R  = Rt(Y1:Y2,X1:X2);

 R  = smooth2(R,2);

 ids = X2-X1+1;
 jds = Y2-Y1+1;

 
 R  = reshape(R,ids*jds,1);
 C  = reshape(C,ids*jds,1);


r = corrcoef(R,C,'rows','pairwise')
 fcC(itime) = r(1,2);

% numer of bins

end % end loop days



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

ylabel('corrcoeff','FontSize',12)
xlabel('Time (days)','FontSize',12)

set(gca,'XTick', 1:30:itime);
set(gca,'XTickLabel',timeBar(1:30:end))

%end
end
end

fileoc = strcat('trend_corr_wcurld_',G,'.eps');

print(fcch,'-dpsc2',fileoc)

close all;

end
