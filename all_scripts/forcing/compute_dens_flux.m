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

day   = textread('../archivesDay_all');
year  = textread('../archivesYear_all');

for region = 5:5

 [X1,X2,Y1,Y2,G] = regions(region);

 lon = tlon(1,X1:X2);
 lat = tlat(Y1:Y2,1);

for time  = 8:9
 time
 lday  = digit(day(time),3);
 lyear = digit(year(time),4);

 if (time == 8)
  daym = 199; % d 200 y 8
 else
  daym = 400; % d 35  y 9 
 end

for did =1:4
 depth = readline('../3D/layersDepth_4',did);
 depthid = str2num(readline('../3D/layersDepthID_4',did));
 depth

for arch = 1:2


n = 0;
lti = -5;
lts = 5;

%for t = lti:1:lts

%lday   = digit(day(daym+t),3)
%lyear  = digit(year(daym+t),4)
%liday  = digit(day(daym),3);
%liyear = digit(time,3);

lday   = digit(day(daym),3)
lyear  = digit(year(daym),4)
liday  = digit(day(daym),3);
liyear = digit(time,3);

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

 hour   = 1 % archive is 00
 idtime = 4*day(daym) + hour;
 
 ttx = hycomread(filee,idm,jdm,ijdm,idtime);
 tty = hycomread(filen,idm,jdm,ijdm,idtime);

% land = landt(Y1:Y2,X1:X2);

 tx = ttx(Y1:Y2,X1:X2);
 ty = tty(Y1:Y2,X1:X2);
 R  = Rt(Y1:Y2,X1:X2);
 fs = fluxs(Y1:Y2,X1:X2);
 ft = fluxt(Y1:Y2,X1:X2);

 R  = smooth2(R,2);

 ids = X2-X1+1;
 jds = Y2-Y1+1;


 
 R  = reshape(R,ids*jds,1);
% C  = reshape(C,ids*jds,1);
 fs = reshape(fs,ids*jds,1);
 ft = reshape(ft,ids*jds,1);

 step = 10;

 R = R(1:step:end);
 fs = fs(1:step:end);
 ft = ft(1:step:end);

% numer of bins

%end % end inner loop days


'plotting...'
if (arch==1)
 fileos = strcat('./plot/scatter_s_h_',liyear,'_',liday,'_',depth,'_',G,'.eps')
 fileot = strcat('./plot/scatter_t_h_',liyear,'_',liday,'_',depth,'_',G,'.eps')
 fileoc = strcat('./plot/scatter_c_h_',liyear,'_',liday,'_',depth,'_',G,'.eps')
else
 fileos = strcat('./plot/scatter_s_l_',liyear,'_',liday,'_',depth,'_',G,'.eps')
 fileot = strcat('./plot/scatter_t_l_',liyear,'_',liday,'_',depth,'_',G,'.eps')
 fileoc = strcat('./plot/scatter_c_l_',liyear,'_',liday,'_',depth,'_',G,'.eps')
end

%%%%%%%%%%%%% c


%%%%%%%%%%% s

[ch] = figure;
p = scatter(R,fs,'+k');
title('salinity flux vs density','FontSize',24)
'saving...'
%ylabel('','FontSize',18)
%xlabel('','FontSize',18)

print(ch,'-dpsc2',fileos)

%%%%%%%%%% t

[ch] = figure;
p = scatter(R,ft,'k');
title('temperature flux vs density','FontSize',24)
'saving...'
%ylabel('','FontSize',18)
%xlabel('','FontSize',18)

print(ch,'-dpsc2',fileot)

close all;

end
end
end
end
