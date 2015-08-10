clear all;
%%%% dimensions  
gridbfid=fopen('../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;

file = '../topo0.02/regional.grid.a';

tlon = hycomread(file,ijdm,1);
tlat = hycomread(file,ijdm,2);

tpscx = hycomread(file,ijdm,10);
tpscy = hycomread(file,ijdm,11);

tplon = hycomread(file,ijdm,12);
tplat = hycomread(file,ijdm,13);

tpscx = reshape(tpscx,idm,jdm);
tpscy = reshape(tpscy,idm,jdm);
tlon = reshape(tlon,idm,jdm);
tlat = reshape(tlat,idm,jdm);

X1 = 472;
X2 = 839;
Y1 = 77;
Y2 = 267;

lon = tlon(X1:X2,1);
lat = tlat(1,Y1:Y2);

pscx = tpscx(X1:X2,Y1:Y2);
pscy = tpscy(X1:X2,Y1:Y2);

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
        lyear = num2str(year);
        lday = num2str(day);

       if(day < 100)
        lday = strcat('0',lday);
        
        if(day < 10)
        lday = strcat('0',lday);
        end 
       end

% x bar for plotting
itime = itime + 1
time(itime) = day;

day    
year

if (arch == 1)
file  = strcat('~/hycom/scripts/kinematics/output/okuboweiss/high-res/okuboweiss_h_016_archv.000',lyear,'_',lday,'_00.a');
else
file  = strcat('~/hycom/scripts/kinematics/output/okuboweiss/low-res/okuboweiss_l_016_archv.000',lyear,'_',lday,'_00.a');
end

tvort = hycomread(file,ijdm,1);

tvort(tvort > 2^10) = NaN;

tvort = tvort/(8*10^-5);

tplon = reshape(tplon,idm,jdm);
tplat = reshape(tplat,idm,jdm);
tvort = reshape(tvort,idm,jdm);

plon = tplon(X1:X2,Y1:Y2);
plat = tplat(X1:X2,Y1:Y2);
vort = tvort(X1:X2,Y1:Y2);


ids = X2-X1+1;
jds = Y2-Y1+1;

m = 0;
t = 0;
tt = 0;


for j = 1:jds
 for i = 1:ids

  if(~isnan(vort(i,j)))
  tt = tt + plon(i,j)*plat(i,j);

   if(vort(i,j) < 0)
    t = t + sqrt(abs(vort(i,j)))*(plon(i,j)*plat(i,j));
   else
    m = m + sqrt(vort(i,j))*(plon(i,j)*plat(i,j));
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

M = M(M ~= pi);
Q = Q(Q ~= pi);

%%%%%% SD normalization

sdM  = nanstd(M);
sdQ  = nanstd(Q);

M = M./sdM;
Q = Q./sdM;

%%%%%%% without SD normalization

%miny = 0;
%maxy = 3.5*10^-3;

%minya = -8*10^-4;
%maxya =  8*10^-4;

%%%%%%% with SD normalization

%miny = 0;
%maxy = 3.5*10^-3;

%minya = -8*10^-4;
%maxya =  8*10^-4;

miny = min(min(min(M),min(Q)),miny);
maxy = max(max(max(M),max(Q)),maxy);


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

t = title('OW^+ and OW^- vs time (region A, high res)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_h_A.eps');

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

t = title('Anomalies OW^+ and OW^- vs time (region A, high res)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_h_a_A.eps');

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

t = title('OW^+ and OW^- vs time (region A, low res)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_l_A.eps');

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

t = title('Anomalies OW^+ and OW^- vs time (region A, low res)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_l_a_A.eps');

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

t = title('OW^+ - OW^-, high and low res, vs time (region A)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_diff_A.eps');


end
end % close archive high/low res loop
