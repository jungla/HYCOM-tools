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

did = 0;

for didi = 2:22

did = did + 1;

delta = readline('./delta_sens',didi);
deltas(did) = str2num(delta);

if (arch == 1)
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_02_h_',delta,'_16_archv.',lyear,'_',lday,'_00_u.a');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_02_h_',delta,'_16_archv.',lyear,'_',lday,'_00_v.a');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_02_h_',delta,'_16_archv.',lyear,'_',lday,'_00_w.a');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_02_h_',delta,'_16_archv.',lyear,'_',lday,'_00_r.a');
 filet   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_02_h_',delta,'_16_archv.',lyear,'_',lday,'_00_t.a');
 files   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/high-res/filter_02_h_',delta,'_16_archv.',lyear,'_',lday,'_00_s.a');
 fileuo   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zu.A');
 filevo   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zv.A');
 filewo   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zw.A');
 filero   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zr.A');
 fileto   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zt.A');
 fileso   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zs.A');
else
 fileu   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_02_l_',delta,'_16_archv.',lyear,'_',lday,'_00_u.a');
 filev   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_02_l_',delta,'_16_archv.',lyear,'_',lday,'_00_v.a');
 filew   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_02_l_',delta,'_16_archv.',lyear,'_',lday,'_00_w.a');
 filer   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_02_l_',delta,'_16_archv.',lyear,'_',lday,'_00_r.a');
 filet   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_02_l_',delta,'_16_archv.',lyear,'_',lday,'_00_t.a');
 files   = strcat('/tamay/mensa/hycom/scripts/3D/filter_delta/output/low-res/filter_02_l_',delta,'_16_archv.',lyear,'_',lday,'_00_s.a');
 fileuo   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zu.A');
 filevo   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zv.A');
 filewo   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zw.A');
 filero   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zr.A');
 fileto   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zt.A');
 fileso   = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zs.A');
end

xc = 1;
yc = 1;

fu = binaryread(fileu,ids,jds,ijds,1);
fv = binaryread(filev,ids,jds,ijds,1);
fw = binaryread(filew,ids,jds,ijds,1);
fr = binaryread(filer,ids,jds,ijds,1);
ft = binaryread(filet,ids,jds,ijds,1);
fs = binaryread(files,ids,jds,ijds,1);
fuo = binaryread(fileuo,ids,jds,ijds,20);
fvo = binaryread(filevo,ids,jds,ijds,20);
fwo = binaryread(filewo,ids,jds,ijds,20);
fro = binaryread(filero,ids,jds,ijds,20);
fto = binaryread(fileto,ids,jds,ijds,20);
fso = binaryread(fileso,ids,jds,ijds,20);

fro = fro + 1000;

fro = fro - mean(fro(~isnan(fro)));
fr = fr - mean(fr(~isnan(fr)));
fso = fso - mean(fso(~isnan(fso)));
fs = fs - mean(fs(~isnan(fs)));
fto = fto - mean(fto(~isnan(fto)));
ft = ft - mean(ft(~isnan(ft)));

Mfro = max(fro(~isnan(fro)));
mfro = min(fro(~isnan(fro)));
Mfr = max(fr(~isnan(fr)));
mfr = min(fr(~isnan(fr)));
Mfso = max(fso(~isnan(fso)));
mfso = min(fso(~isnan(fso)));
Mfs = max(fs(~isnan(fs)));
mfs = min(fs(~isnan(fs)));
Mfto = max(fto(~isnan(fto)));
mfto = min(fto(~isnan(fto)));
Mft = max(ft(~isnan(ft)));
mft = min(ft(~isnan(ft)));

%fro = (Mfro - fro)./(Mfro - mfro);
%fr = (Mfr - fr)./(Mfr - mfr);
%fto = (Mfto - fto)./(Mfto - mfto);
%ft = (Mft - ft)./(Mft - mft);
%fso = (Mfso - fso)./(Mfso - mfso);
%fs = (Mfs - fs)./(Mfs - mfs);

rms = sqrt((fu - fuo).^2);
RMSU(did) = sum(rms(~isnan(rms)))
rms = sqrt((fv - fvo).^2);
RMSV(did) = sum(rms(~isnan(rms)))
rms = sqrt((fw - fwo).^2);
RMSW(did) = sum(rms(~isnan(rms)))
rms = sqrt((fr - fro).^2);
RMSR(did) = sum(rms(~isnan(rms)))
rms = sqrt((ft - fto).^2);
RMST(did) = sum(rms(~isnan(rms)))
rms = sqrt((fs - fso).^2);
RMSS(did) = sum(rms(~isnan(rms)))

%ch = figure();
%subplot(2,1,1), imagesc(lat,lon,fs);
%%caxis([1034 1035])
%colorbar;
%subplot(2,1,2), imagesc(lat,lon,fso);
%label = strcat('./plot/high-res/filter_fs_',delta,'_',lyear,'_',lday,'_h_',R,'.eps')
%%caxis([1034 1035])
%colorbar;
%print(ch,'-dpsc2',label);
%close;

%ch = figure();
%subplot(2,1,1), imagesc(lat,lon,ft);
%%caxis([1034 1035])
%colorbar;
%subplot(2,1,2), imagesc(lat,lon,fto);
%label = strcat('./plot/high-res/filter_ft_',delta,'_',lyear,'_',lday,'_h_',R,'.eps')
%%caxis([1034 1035])
%colorbar;
%print(ch,'-dpsc2',label);
%close;


end % delta

RMSUN = (RMSU-min(RMSU))./(max(RMSU)-min(RMSU));
RMSVN = (RMSV-min(RMSV))./(max(RMSV)-min(RMSV));
RMSWN = (RMSW-min(RMSW))./(max(RMSW)-min(RMSW));
RMSRN = (RMSR-min(RMSR))./(max(RMSR)-min(RMSR));
RMSSN = (RMSS-min(RMSS))./(max(RMSS)-min(RMSS));
RMSTN = (RMST-min(RMST))./(max(RMST)-min(RMST));

%%%%%%%%%%%%%%%%%%

 [ch] = figure();
 
 p1 = plot(deltas,RMSUN,'r-+','LineWidth',1.2);
 hold on;
 p2 = plot(deltas,RMSVN,'b-+','LineWidth',1.2);
% p3 = plot(deltas,RMSWN,'r-+','LineWidth',1.2);
 p4 = plot(deltas,RMSRN,'k-+','LineWidth',1.2);
% p5 = plot(deltas,RMSTN,'y-+','LineWidth',1.2);
% p6 = plot(deltas,RMSSN,'m-+','LineWidth',1.2);

% legend([p1 p2 p3 p4 p5 p6],{'u', 'v', 'w', 'r', 't', 's'});
 legend([p1 p2 p4],{'u', 'v', 'r'},'FontSize',18);
 ylabel('D','FontSize',21)
 xlabel('\lambda (Km)','FontSize',21)
 set(gca,'FontSize',18) 

if (arch == 1)
 label = strcat('./plot/high-res/filter_delta_',lyear,'_',lday,'_h_',R,'.eps')
else
 label = strcat('./plot/low-res/filter_delta_',lyear,'_',lday,'_l_',R,'.eps')
end 

 'saving...'
 print(ch,'-dpsc2',label)
 close all;

end % end day
end % end arch

