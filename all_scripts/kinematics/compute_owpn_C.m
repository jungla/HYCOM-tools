clear all;
%%%% dimensions  
gridbfid=fopen('../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
IDM=sscanf(line,'%f',1);
line=fgetl(gridbfid);
JDM=sscanf(line,'%f',1);
KDM=32;
R='GSa0.02'; 
E='016'; 
T='08';
Y='0008_062'
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
iif=1
iil=IDM
jjf=1
jjl=JDM
idm=iil-iif+1; jdm=jjl-jjf+1;kdm=KDM;
i1=iif; i2=iil; j1=jjf; j2=jjl

IJDM=IDM*JDM;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file = '../topo0.02/regional.grid.a';

tlon = hycomread(file,IJDM,1);
tlat = hycomread(file,IJDM,2);

tpscx = hycomread(file,IJDM,10);
tpscy = hycomread(file,IJDM,11);

tplon = hycomread(file,IJDM,12);
tplat = hycomread(file,IJDM,13);

tpscx = reshape(tpscx,jdm,idm);
tpscy = reshape(tpscy,jdm,idm);
tlon = reshape(tlon,jdm,idm);
tlat = reshape(tlat,jdm,idm);

X1 = 619;
X2 = 986;
Y1 = 774;
Y2 = 900;

lon = tlon(Y1:Y2,1);
lat = tlat(1,X1:X2);

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

tvort = hycomread(file,IJDM,1);

tvort(tvort > 2^10) = NaN;

tvort = tvort/(8*10^-5);

tplon = reshape(tplon,IDM,JDM)';
tplat = reshape(tplat,IDM,JDM)';
tvort = reshape(tvort,IDM,JDM)';

plon = tplon(Y1:Y2,X1:X2);
plat = tplat(Y1:Y2,X1:X2);
vort = tvort(Y1:Y2,X1:X2);

jdm = X2-X1;
idm = Y2-Y1;

m = 0;
t = 0;
tt = 0;


for i = 1:idm
 for j = 1:jdm

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

miny = 0;
maxy = 3.5*10^-3;

minya = -8*10^-4;
maxya =  8*10^-4;


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

t = title('OW^+ and OW^- vs time (region C, high res)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_h_C.eps');

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

t = title('Anomalies OW^+ and OW^- vs time (region C, high res)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_h_a_C.eps');

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

t = title('OW^+ and OW^- vs time (region C, low res)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_l_C.eps');

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

t = title('Anomalies OW^+ and OW^- vs time (region C, low res)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_l_a_C.eps');


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

t = title('OW^+ - OW^-, high and low res, vs time (region C)');
set(t,'FontSize',18)
print(owml,'-dpsc2','OW+_OW-_diff_C.eps');



end

end % close archive high/low res loop

