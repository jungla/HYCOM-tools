clear all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../../topo0.02/regional.grid.a';

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

tpscx = hycomread(file,idm,jdm,ijdm,12);
tpscy = hycomread(file,idm,jdm,ijdm,13);

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi = 1;
dayf = 498;
dstep = 1;

for arch = 1:2

miny =  100;
maxy = -100;

%Q(1:dayi*dayf*2) = pi;
%M(1:dayi*dayf*2) = pi;

for did = 1:1

depth   = readline('../../3D/layersDepth_4',did);
depthid = str2num(readline('../../3D/layersDepthID_4',did));

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../../archivesDay_all');
year  = textread('../../archivesYear_all');

lday  = digit(day(time),3)
lyear = digit(year(time),4)


% x bar for plotting
itime = itime + 1;

% x bar for plotting
timeBar(itime) = day(time);


if (arch == 1)
file  = strcat('./output/high-res/okuboweiss_a_h_016_archv.',lyear,'_',lday,'_00.a');
else
file  = strcat('./output/low-res/okuboweiss_a_l_016_archv.',lyear,'_',lday,'_00.a');
end

tow = binaryread(file,idm,jdm,ijdm,did);

ow = tow(Y1:Y2,X1:X2);


jds = X2-X1+1;
ids = Y2-Y1+1;

m = 0;
t = 0;
tt = 0;
mm = 0;

for j = 1:jds
 for i = 1:ids

  if(~isnan(ow(i,j)))
   tt = tt + pscx(i,j)*pscy(i,j);

   if(ow(i,j) < 0)
    t = t + sqrt(abs(ow(i,j)))*(pscx(i,j)*pscy(i,j));
   elseif(ow(i,j) > 0)
    m = m + sqrt(ow(i,j))*(pscx(i,j)*pscy(i,j));
   end

  end

 end
end

 if(tt > 0)
 M(mmm) = t/tt;
 Q(mmm) = m/tt;
 mmm = mmm + 1;
 end

 end % day  loop
end  % year loop

%%%%%%% without SD normalization

if (arch==1)
 miny = 0;
 maxy = 2*10^-5;
 minya = -6*10^-6;
 maxya =  6*10^-6;
else
 miny = 0;
 maxy = 1*10^-5;
 minya = -3*10^-6;
 maxya =  3*10^-6;
end

%%%%%%% with SD normalization

%miny = 0;
%maxy = 3.5*10^-3;

%minya = -8.5*10^-6;
%maxya =  8.5*10^-6;


%miny = min(min(min(M),min(Q)),miny);
%maxy = max(max(max(M),max(Q)),maxy);

owml = figure;
[AX1 H11 H21] = plotyy(2:itime+1,M,2:itime+1,Q, 'plot')
set(H11,'LineStyle','-','linewidth',2,'Color','black');
set(H21,'LineStyle','-','linewidth',2,'Color','blue');
set(AX1(1),'ycolor','k') 
set(AX1(2),'ycolor','b')

set(get(AX1(1),'Ylabel'),'String','Q^- (s^{-1})','FontSize',18)
set(get(AX1(2),'Ylabel'),'String','Q^+ (s^{-1})','FontSize',18)

axes(AX1(1));
axis([2 itime+1 miny maxy]);
set(AX1(1),'FontSize',18);
set(AX1(1),'XTickLabel',[])

axes(AX1(2));
axis([2 itime+1 miny maxy]);
xlabel('Time (days)','FontSize',18)
set(AX1(2),'FontSize',18)

%t = title('OW^+ and OW^- vs time (region A, high res)');
%set(t,'FontSize',18)

% plot anomalies

owmla = figure;
[AX1 H11 H21] = plotyy(2:itime+1,M-mean(M),2:itime+1,Q-mean(Q), 'plot');
set(H11,'LineStyle','-','linewidth',2,'Color','black');
set(H21,'LineStyle','-','linewidth',2,'Color','blue');
set(AX1(1),'ycolor','k') 
set(AX1(2),'ycolor','b')

set(get(AX1(1),'Ylabel'),'String','Q^- (s^{-1})','FontSize',18)
set(get(AX1(2),'Ylabel'),'String','Q^+ (s^{-1})','FontSize',18)

axes(AX1(1));
axis([2 itime+1 minya maxya]);
set(AX1(1),'FontSize',18);
set(AX1(1),'XTickLabel',[])

axes(AX1(2));
axis([2 itime+1 minya maxya]);
xlabel('Time (days)','FontSize',18)
set(AX1(2),'FontSize',18)

if (arch == 1)

TM = M;
TQ = Q;

print(owml,'-dpsc2',strcat('./plot/OW+_OW-_h_',R,'.eps'));
print(owmla,'-dpsc2',strcat('./plot/OW+_OW-_h_a_',R,'.eps'));

close all;

else

print(owml,'-dpsc2',strcat('./plot/OW+_OW-_l_',R,'.eps'));
print(owmla,'-dpsc2',strcat('./plot/OW+_OW-_l_a_',R,'.eps'));

minyd = -2*10^-6;
maxyd =  2*10^-6;

owmld = figure;
[AX1 H11 H21] = plotyy(2:itime+1,TM-M,2:itime+1,TQ-Q, 'plot');
set(H11,'LineStyle','-','linewidth',2,'Color','black');
set(H21,'LineStyle','-','linewidth',2,'Color','blue');
set(AX1(1),'ycolor','k') 
set(AX1(2),'ycolor','b')

set(get(AX1(1),'Ylabel'),'String','Q^- high res - Q^- low res (s^{-1})','FontSize',18)
set(get(AX1(2),'Ylabel'),'String','Q^+ high res - Q^+ low res (s^{-1})','FontSize',18)

axes(AX1(1));
axis([2 itime+1 minyd maxyd]);
set(AX1(1),'FontSize',18);
set(AX1(1),'XTickLabel',[])

axes(AX1(2));
axis([2 itime+1 minyd maxyd]);
xlabel('Time (days)','FontSize',18)
set(AX1(2),'FontSize',18)

%t = title('OW^+ - OW^-, high and low res, vs time (region A)');
%set(t,'FontSize',18)
print(owmld,'-dpsc2',strcat('./plot/OW+_OW-_diff_',R,'.eps'));

close all;

end
end % close archive high/low res loop
end % region loop
