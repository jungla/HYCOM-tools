clear all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

tplon = hycomread(file,idm,jdm,ijdm,18);
tplat = hycomread(file,idm,jdm,ijdm,13);

for region = 6:6

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 49;
dstep = 1;


for arch = 1:1

owml = figure;

for did = 31:31

depth   = readline('../../3D/layersDepth_ML',did);
depthid = str2num(readline('../../3D/layersDepthID_ML',did));

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;


clear wM;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../../3D/archivesDay');
year  = textread('../../3D/archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;

% x bar for plotting
timeBar(itime) = day(time);

arch
lday
lyear
depth

if (arch == 1)
 file1  = strcat('./output/high-res/O_a_h_',lyear,'_',lday,'_00.a');
 file2  = strcat('/tamay/mensa/hycom/GSa0.0x_ML/016_archv.',lyear,'_',lday,'_00_ML_3zr.A');
else
 file1  = strcat('./output/low-res/O_a_l_',lyear,'_',lday,'_00.a');
 file2  = strcat('/tamay/mensa/hycom/GSa0.0x_ML/archv.',lyear,'_',lday,'_00_ML_3zr.A');
end

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;

Oat = binaryread(file1,ids,jds,ijds,depthid);
Oat = abs(Oat);

% Brunt Vaisala frequency

% build r0
for dr0 = 1:41
r0(dr0) = nansum(nansum(binaryread(file2,ids,jds,ijds,dr0)));
end

 r1 = binaryread(file2,ids,jds,ijds,depthid-1);
 r2 = binaryread(file2,ids,jds,ijds,depthid+1);

  
 
 N(dr0) = nanmean(nanmean(9.806*(r2-r1)));./(4*(mean(r0+1000)))));

OaM(itime) = avg_region(Oat,tpscx,tpscy,1,ids,1,jds,0)
NM(itime) = nansum(N)

end % day loop

figure(owml);

[AX1 H11 H21] = plotyy(dayi:dayf,OaM,dayi:dayf,NM, 'plot');
set(H11,'LineStyle','-','linewidth',2,'Color','black');
set(H21,'LineStyle','-','linewidth',2,'Color','blue');
set(AX1(1),'ycolor','k')
set(AX1(2),'ycolor','b')

set(get(AX1(1),'Ylabel'),'String','<|\omega_a|>','FontSize',18)
set(get(AX1(2),'Ylabel'),'String','<N^2>','FontSize',18)

axes(AX1(1));
axis([2 itime+1 0 5*10e-6]);
set(AX1(1),'FontSize',18);
set(AX1(1),'XTickLabel',[])

axes(AX1(2));
axis([2 itime+1 min(NM) max(NM)]);
xlabel('Time (days)','FontSize',18)
set(AX1(2),'FontSize',18)
set(AX1(2),'XTickLabel',[],'FontSize',15)

%t = title('OW^+ - OW^-, high and low res, vs time (region A)');
%set(t,'FontSize',18)

end % depth loop

if (arch == 1)
 print(owml,'-dpsc2',strcat('./plot/Oa_N_h_',R,'.eps'))
else
 print(owml,'-dpsc2',strcat('./plot/Oa_N_l_',R,'.eps'))
end
 close all;
end % close archive high/low res loop


%close all;
end  % region loop
