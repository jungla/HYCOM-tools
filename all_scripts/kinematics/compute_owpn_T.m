clear all;
%%%% dimensions  
gridbfid=fopen('../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

tpscx = hycomread(file,idm,jdm,ijdm,12);
tpscy = hycomread(file,idm,jdm,ijdm,13);

for region = 1:4

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi = 1;
dayf = 366;

for arch = 1:2

miny =  100;
maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;
itime = 0;

Q(1:dayi*dayf*2) = pi;
M(1:dayi*dayf*2) = pi;

for year = 8:9
 for day  = dayi:dayf
 if ((year ~= 8) || (day ~= 1))

  if ((year == 9) && (day >= 133))
   break;
  end

lday  = digit(day,3);
lyear = digit(year,4);

lday
lyear


% x bar for plotting
itime = itime + 1
time(itime) = day;

day    
year
R

if (arch == 1)
 file  = strcat('./output/dssv/high-res/okuboweiss_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file  = strcat('./output/dssv/low-res/okuboweiss_l_016_archv.',lyear,'_',lday,'_00.a');
end

tow = hycomread(file,idm,jdm,ijdm,1);

ow = tow(Y1:Y2,X1:X2);

stdow = std(ow(~isnan(ow)))

jds = X2-X1+1;
ids = Y2-Y1+1;

m = 0;
t = 0;
tt = 0;

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

 end % if condition
 end % day  loop
end  % year loop

%%%%%%% without SD normalization

miny = 0;
maxy = 3*10^-5;

%minya = -8*10^-4;
%maxya =  8*10^-4;

%%%%%%% with SD normalization

%miny = 0;
%maxy = 3.5*10^-3;

minya = -8.5*10^-6;
maxya =  8.5*10^-6;

M = M(M ~= pi);
Q = Q(Q ~= pi);

%miny = min(min(min(M),min(Q)),miny);
%maxy = max(max(max(M),max(Q)),maxy);


if (arch == 1)

%% I save M and Q in two temporary arrays to plot later the differences...
TM = M;
TQ = Q;

owml = figure;
[AX1 H11 H21] = plotyy(2:itime+1,M,2:itime+1,Q, 'plot')
set(H11,'LineStyle','-','linewidth',2)
set(H21,'LineStyle','-','linewidth',2)

set(get(AX1(1),'Ylabel'),'String','OW^- (s^{-1})','FontSize',14)
set(get(AX1(2),'Ylabel'),'String','OW^+ (s^{-1})','FontSize',14)

axes(AX1(1));
axis([2 itime+1 miny maxy]);
set(AX1(1),'FontSize',14);
set(AX1(1),'XTickLabel',[])

axes(AX1(2));
axis([2 itime+1 miny maxy]);
xlabel('Time (days)','FontSize',14)
set(AX1(2),'FontSize',14)

%t = title('OW^+ and OW^- vs time (region A, high res)');
%set(t,'FontSize',18)
print(owml,'-dpsc2',strcat('./plot/OW+_OW-_h_',R,'.eps'));

% plot anomalies

owml = figure;
[AX1 H11 H21] = plotyy(2:itime+1,M-mean(M),2:itime+1,Q-mean(Q), 'plot')
set(H11,'LineStyle','-','linewidth',2)
set(H21,'LineStyle','-','linewidth',2)

set(get(AX1(1),'Ylabel'),'String','OW^- (s^{-1})','FontSize',14)
set(get(AX1(2),'Ylabel'),'String','OW^+ (s^{-1})','FontSize',14)

axes(AX1(1));
axis([2 itime+1 minya maxya]);
set(AX1(1),'FontSize',14);
set(AX1(1),'XTickLabel',[])

axes(AX1(2));
axis([2 itime+1 minya maxya]);
xlabel('Time (days)','FontSize',14)
set(AX1(2),'FontSize',14)

%t = title('Anomalies OW^+ and OW^- vs time (region A, high res)');
%set(t,'FontSize',18)
print(owml,'-dpsc2',strcat('./plot/OW+_OW-_h_a_',R,'.eps'));

else

owml = figure;
[AX1 H11 H21] = plotyy(2:itime+1,M,2:itime+1,Q, 'plot')
set(H11,'LineStyle','-','linewidth',2)
set(H21,'LineStyle','-','linewidth',2)

set(get(AX1(1),'Ylabel'),'String','OW^- (s^{-1})','FontSize',14)
set(get(AX1(2),'Ylabel'),'String','OW^+ (s^{-1})','FontSize',14)

axes(AX1(1));
axis([2 itime+1 miny maxy]);
set(AX1(1),'FontSize',14);
set(AX1(1),'XTickLabel',[])

axes(AX1(2));
axis([2 itime+1 miny maxy]);
xlabel('Time (days)','FontSize',14)
set(AX1(2),'FontSize',14)

%t = title('OW^+ and OW^- vs time (region A, low res)');
%set(t,'FontSize',18)
print(owml,'-dpsc2',strcat('./plot/OW+_OW-_l_',R,'.eps'));

% plot anomalies

owml = figure;
[AX1 H11 H21] = plotyy(2:itime+1,M-mean(M),2:itime+1,Q-mean(Q), 'plot')
set(H11,'LineStyle','-','linewidth',2)
set(H21,'LineStyle','-','linewidth',2)

set(get(AX1(1),'Ylabel'),'String','OW^- (s^{-1})','FontSize',14)
set(get(AX1(2),'Ylabel'),'String','OW^+ (s^{-1})','FontSize',14)

axes(AX1(1));
axis([2 itime+1 minya maxya]);
set(AX1(1),'FontSize',14);
set(AX1(1),'XTickLabel',[])

axes(AX1(2));
axis([2 itime+1 minya maxya]);
xlabel('Time (days)','FontSize',14)
set(AX1(2),'FontSize',14)

%t = title('Anomalies OW^+ and OW^- vs time (region A, low res)');
%set(t,'FontSize',18)
print(owml,'-dpsc2',strcat('./plot/OW+_OW-_l_a_',R,'.eps'));

% plot differences

minyd = -2*10^-4;
maxyd = 15*10^-4;

owml = figure;
[AX1 H11 H21] = plotyy(2:itime+1,TM-M,2:itime+1,TQ-Q, 'plot')
set(H11,'LineStyle','-','linewidth',2)
set(H21,'LineStyle','-','linewidth',2)

set(get(AX1(1),'Ylabel'),'String','OW^- high res - OW^- low res (s^{-1})','FontSize',14)
set(get(AX1(2),'Ylabel'),'String','OW^+ high res - OW^+ low res (s^{-1})','FontSize',14)

axes(AX1(1));
axis([2 itime+1 minyd maxyd]);
set(AX1(1),'FontSize',14);
set(AX1(1),'XTickLabel',[])

axes(AX1(2));
axis([2 itime+1 minyd maxyd]);
xlabel('Time (days)','FontSize',14)
set(AX1(2),'FontSize',14)

%t = title('OW^+ - OW^-, high and low res, vs time (region A)');
%set(t,'FontSize',18)
print(owml,'-dpsc2',strcat('./plot/OW+_OW-_diff_',R,'.eps'));


end
end % close archive high/low res loop
end % region loop
