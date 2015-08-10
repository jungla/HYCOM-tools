clear all;

gridbfid=fopen('/tamay/mensa/hycom/scripts/topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
ijdm = idm*jdm;

file = '/tamay/mensa/hycom/scripts/topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

maxr = 1;
minr = -1;
maxtr = -10;
mintr = 10;

N = 22;

X1 = 1
Y1 = 1
X2 = 1573
Y2 = 1073
R = 'T'

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

[X1A,X2A,Y1A,Y2A,R] = regions(5);
 
pscx = tpscx(Y1A:Y2A,X1A:X2A);
pscy = tpscy(Y1A:Y2A,X1A:X2A);

ids = X2A-X1A+1; % of region A
jds = Y2A-Y1A+1;
ijds = ids*jds;

for arch = 1:1

for time  = 2:2

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_2');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_2');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

for did = 1:20

delta = readline('./delta',did);
deltas(did) = str2num(delta);

for did2 = 1:27

depth = readline('../layersDepth_ML_27',did2);
depths(did2) = str2num(depth);

if (arch == 1)
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_l_h_',delta,'_archv.',lyear,'_',lday,'_00_u.a');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_l_h_',delta,'_archv.',lyear,'_',lday,'_00_v.a');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_l_h_',delta,'_archv.',lyear,'_',lday,'_00_w.a');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_l_h_',delta,'_archv.',lyear,'_',lday,'_00_r.a');
 filet   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_l_h_',delta,'_archv.',lyear,'_',lday,'_00_t.a');
 files   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_l_h_',delta,'_archv.',lyear,'_',lday,'_00_s.a');
 fileuo   = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zu.a');
 filevo   = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zv.a');
 filewo   = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zw.a');
 filero   = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zr.a');
 fileto   = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zt.a');
 fileso   = strcat('/nethome/jmensa/HYCOM/scripts/arcv2data3z/Data_out/016_archv.',lyear,'_',lday,'_00_3zs.a');
else
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_l_l_',delta,'_archv.',lyear,'_',lday,'_00_u.a');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_l_l_',delta,'_archv.',lyear,'_',lday,'_00_v.a');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_l_l_',delta,'_archv.',lyear,'_',lday,'_00_w.a');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_l_l_',delta,'_archv.',lyear,'_',lday,'_00_r.a');
 filet   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_l_l_',delta,'_archv.',lyear,'_',lday,'_00_t.a');
 files   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_l_l_',delta,'_archv.',lyear,'_',lday,'_00_s.a');
 fileu   = strcat('/nethome/jmensa/scripts_hycom/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_u.a');
 filev   = strcat('/nethome/jmensa/scripts_hycom/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_v.a');
 filew   = strcat('/nethome/jmensa/scripts_hycom/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_w.a');
 filer   = strcat('/nethome/jmensa/scripts_hycom/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_r.a');
 filet   = strcat('/nethome/jmensa/scripts_hycom/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_t.a');
 files   = strcat('/nethome/jmensa/scripts_hycom/3D/filter/output/low-res/filter_l_016_archv.',lyear,'_',lday,'_00_s.a');
end

xc = 1;
yc = 1;

fu = binaryread(fileu,ids,jds,ijds,1);
fv = binaryread(filev,ids,jds,ijds,1);
fw = binaryread(filew,ids,jds,ijds,1);
fr = binaryread(filer,ids,jds,ijds,1);
%ft = binaryread(filet,ids,jds,ijds,1);
%fs = binaryread(files,ids,jds,ijds,1);
fuo = binaryread(fileuo,ids,jds,ijds,did2);
fvo = binaryread(filevo,ids,jds,ijds,did2);
fwo = binaryread(filewo,ids,jds,ijds,did2);
fro = binaryread(filero,ids,jds,ijds,did2);
%fto = binaryread(fileto,ids,jds,ijds,did2);
%fso = binaryread(fileso,ids,jds,ijds,did2);

fro = fro + 1000;
fro = fro - mean(fro(~isnan(fro)));
fr = fr - mean(fr(~isnan(fr)));

rms = sqrt((fu - fuo).^2);
RMSU(did,did2) = sum(rms(~isnan(rms)))
rms = sqrt((fv - fvo).^2);
RMSV(did,did2) = sum(rms(~isnan(rms)))
rms = sqrt((fw - fwo).^2);
RMSW(did,did2) = sum(rms(~isnan(rms)))
rms = sqrt((fr - fro).^2);
RMSR(did,did2) = sum(rms(~isnan(rms)))
%rms = sqrt((ft - fto).^2);
%RMST(did) = sum(rms(~isnan(rms)))
%rms = sqrt((fs - fso).^2);
%RMSS(did) = sum(rms(~isnan(rms)))


%ch = figure();
%subplot(2,1,1), imagesc(lat,lon,fr);
%subplot(2,1,2), imagesc(lat,lon,fro);
%label = strcat('./plot/high-res/filter_fr_',delta,'_',lyear,'_',lday,'_h_',R,'.eps')
%print(ch,'-dpsc2',label);
%close;

end % depths
end % delta

%RMSUN = (RMSU-min(RMSU))./(max(RMSU)-min(RMSU));
%RMSVN = (RMSV-min(RMSV))./(max(RMSV)-min(RMSV));
%RMSWN = (RMSW-min(RMSW))./(max(RMSW)-min(RMSW));
%RMSRN = (RMSR-min(RMSR))./(max(RMSR)-min(RMSR));
%RMSSN = (RMSS-min(RMSS))./(max(RMSS)-min(RMSS));
%RMSTN = (RMST-min(RMST))./(max(RMST)-min(RMST));

%%%%%%%%%%%%%%%%%%


 [ch] = figure(); 
 p1 = surf(depths,deltas,RMSU);
 title('u');
 zlabel('sqrt((F - O)^2)','FontSize',12)
 ylabel('delta (Km)','FontSize',12)
 xlabel('depths (m)','FontSize',12)
if (arch == 1)
 label = strcat('./plot/high-res/filter_delta_depth_u_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/filter_delta_depth_u_',lyear,'_',lday,'_l_',R,'.eps')
end 
 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure(); 
 p1 = surf(depths,deltas,RMSV);
 title('v');
 zlabel('sqrt((F - O)^2)','FontSize',12)
 ylabel('delta (Km)','FontSize',12)
 xlabel('depths (m)','FontSize',12)
if (arch == 1)
 label = strcat('./plot/high-res/filter_delta_depth_v_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/filter_delta_depth_v_',lyear,'_',lday,'_l_',R,'.eps')
end 
 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure(); 
 p1 = surf(depths,deltas,RMSW);
 title('w');
 zlabel('sqrt((F - O)^2)','FontSize',12)
 ylabel('delta (Km)','FontSize',12)
 xlabel('depths (m)','FontSize',12)
if (arch == 1)
 label = strcat('./plot/high-res/filter_delta_depth_w_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/filter_delta_depth_w_',lyear,'_',lday,'_l_',R,'.eps')
end 
 'saving...'
 print(ch,'-dpsc2',label)
 close all;

 [ch] = figure(); 
 p1 = surf(depths,deltas,RMSR);
 title('\rho');
 zlabel('sqrt((F - O)^2)','FontSize',12)
 ylabel('delta (Km)','FontSize',12)
 xlabel('depths (m)','FontSize',12)
if (arch == 1)
 label = strcat('./plot/high-res/filter_delta_depth_r_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/filter_delta_depth_r_',lyear,'_',lday,'_l_',R,'.eps')
end 
 'saving...'
 print(ch,'-dpsc2',label)
 close all;

% p2 = plot(deltas,RMSVN,'g-+','LineWidth',1.2);
% p3 = plot(deltas,RMSWN,'r-+','LineWidth',1.2);
% p4 = plot(deltas,RMSRN,'b-+','LineWidth',1.2);
% p5 = plot(deltas,RMSTN,'y-+','LineWidth',1.2);
% p6 = plot(deltas,RMSSN,'m-+','LineWidth',1.2);

end % end day
end % end arch

