clear; close all;

gridbfid = fopen('../topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
ijdm = idm*jdm;

file = '../topo0.02/regional.grid.a';

pscx = hycomread(file,idm,jdm,ijdm,10);
pscy = hycomread(file,idm,jdm,ijdm,11);

dayi  = 1;    % variables for day loop
dayf  = 366;  %
dstep = 1;   %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stratification variables
dmax = 1000;
dday = 1;

maxr = 0;
minr = 100;
maxN2 = -100;
minN2 = 100;

maxtr = -10;
mintr = 10;
maxtN2 = -10;
mintN2 = 10;

for region = 1:4

itime = 0;

[X1,X2,Y1,Y2,R] = regions(region);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first check overall max density and frequency to plot...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



 N = 30;
 M = size(text,1);

for arch = 1:2

for year = 8:9

for day  = dayi:dstep:dayf-dstep
 if ((year ~= 8) || (day ~= 1))
 if ((year == 9) && (day >= 133))
 break;
 end

 lyear = num2str(year);
 lday = day_digit(day);


 lday
 lyear


clear r z N2

 if (arch == 1)
  text  = textread(strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/high-res/',R,'/density_s_h_016_archv.000',lyear,'_',lday,'_',R,'0_00.dat'));
 else
  text  = textread(strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/low-res/',R,'/density_s_l_016_archv.000',lyear,'_',lday,'_',R,'0_00.dat'));
 end

  z  = text(:,2); % depth
  r  = text(:,3); % density

% add a first point at z = 0.
  z(1) = 0;
  r(1) = r(2);

 gr0 = sum(z)*9.81/sum(z.*r); % g/r0 

 N2(1) = gr0*(r(2)-r(1))/(z(2)-z(1));

 N2(N) = gr0*(r(N)-r(N-1))/(z(N)-z(N-1));

 for j = 2:N-1
  N2(j) = gr0*(r(j+1)-r(j-1))/(z(j+1)-z(j-1));
 end

 % interpolation vectors
 zi = 0:1:dmax;
 N2i = interp1(z,N2,zi,'linear');

 if (arch == 1)
  tN2i = N2i;
 else
  maxtN2 = max(maxtN2,max(tN2i-N2i));
  mintN2 = min(mintN2,min(tN2i-N2i));
 end


 maxN2 = max(maxN2,max(N2i));
 minN2 = min(minN2,min(N2i));

end % if
end % days
end % days
end % years

maxN2
minN2

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %          real computation
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 Nl = 30;
 M = size(text,1);

for arch = 1:2

 itime = 0;

for year = 8:9

for day  = dayi:dstep:dayf-dstep
 if ((year ~= 8) || (day ~= 1))
 if ((year == 9) && (day >= 133))
 break;
 end

 lyear = num2str(year);
 lday = day_digit(day);

 lday
 lyear

clear r z N2

 itime = itime + 1;


 if (arch == 1)
  text  = textread(strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/high-res/',R,'/density_s_h_016_archv.000',lyear,'_',lday,'_',R,'0_00.dat'));
 else
  text  = textread(strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/low-res/',R,'/density_s_l_016_archv.000',lyear,'_',lday,'_',R,'0_00.dat'));
 end

  z  = text(:,2); % depth

% rebuild depth... this should GOGOGO!!!
 for n=2:Nl
  z(n) = z(n) + z(n-1);
 end

  r  = text(:,3); % density

% add a first point at z = 0.
  z(1) = 0;
  r(1) = r(2);

 gr0 = sum(z)*9.81/sum(z.*r); % g/r0 

 N2(1) = gr0*(r(2)-r(1))/(z(2)-z(1));

 N2(Nl) = gr0*(r(Nl)-r(Nl-1))/(z(Nl)-z(Nl-1));

 for j = 2:Nl-1
  N2(j) = gr0*(r(j+1)-r(j-1))/(z(j+1)-z(j-1));
 end

 % interpolation vectors
 zi = 0:1:dmax;
 N2i = interp1(z,N2,zi,'linear');

% save integrated N in time... I integrate over 300 m

 sN2(itime) = sum(N2i(zi < 300));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end of density script... it may be simplyfied a little...

clear p pf ket ke kea

% x bar for plotting
time(itime) = day;

pf = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Compute Spectra      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if (arch == 1)
  file = strcat('../energy/output/ke04/high-res/keenergy_h_016_archv.000',lyear,'_',lday,'_04_00.a');
 else
  file = strcat('../energy/output/ke04/low-res/keenergy_l_016_archv.000',lyear,'_',lday,'_04_00.a');
 end
    
 kea = hycomread(file,idm,jdm,ijdm,1);

% it sums n spectra, taking nsp/ssp sections each ssp points.

 spscx = 0;

 if(arch == 1)
  step = 1;
 else
  step = 4;
 end

[dx,ke,s,pf,f,N] = spectrum_2D(X1,X2,Y1,Y2,kea,pscx,step);

% print some diagnostics

 R
 arch


  f = 1/(N*dx):1/(N*dx):1/(2*dx);

% compute values of energy for wavenumber > 0.033 Km (30 Km wave length)

 ske  = sum(pf(f>0.033));
 sske = sum(pf(f>0.020));
 
 K(itime)  = ske;
 Ks(itime) = sske;

end % close if day
end % close day
end % close year

if (arch == 1)

TsN2 = sN2;

keN = figure;
plot(sN2,'-b','linewidth',2);
title(strcat(['Brunt-Vaisala freq in Time (region ',R,', high-res)']),'fontsize',18);
xlabel('time (days)','fontsize',14)
ylabel('N^2 (s^{-2})','fontsize',14)
%ylim([0 270]);
label = strcat('Brunt_Vaisala_h_',R,'.eps')
print(keN,'-dpsc2',label);

skep = figure;
[AX H1 H2] = plotyy(1:itime,Ks,1:itime,K, 'plot')
set(get(AX(1),'Ylabel'),'String','KEs (m^2/s^2)','fontsize',12)
set(get(AX(2),'Ylabel'),'String','KE (m^2/s^2)','fontsize',12)

axes(AX(1));
%axis([2 itime+1 0 270]);
set(AX(1),'FontSize',12);
set(AX(1),'XTickLabel',[])

axes(AX(2));
%axis([2 itime+1 0 6*10^-3]);
xlabel('Time (days)','FontSize',12)
set(AX(2),'FontSize',14)

title(strcat(['KE below 33km and KE below 20km vs Time (region ',R,', high-res)']),'fontsize',16);
set(H1,'LineStyle','-','linewidth',2);
set(H2,'LineStyle','-','linewidth',2);
label = strcat('KE_KEs_h_',R,'.eps')
print(skep,'-dpsc2',label);

owml = figure;
[AX H1 H2] = plotyy(1:itime,sN2,1:itime,K, 'plot')
set(get(AX(1),'Ylabel'),'String','N^2 (s^{-2})','fontsize',12)
set(get(AX(2),'Ylabel'),'String','KE (m^2/s^2)','fontsize',12)

axes(AX(1));
%axis([2 itime+1 0 270]);
set(AX(1),'FontSize',12);
set(AX(1),'XTickLabel',[])

axes(AX(2));
%axis([2 itime+1 0 6*10^-3]);
xlabel('Time (days)','FontSize',12)
set(AX(2),'FontSize',14)

title(strcat(['KE and Mixed Layer Depth vs Time (region ',R,', high-res)']),'fontsize',16);
set(H1,'LineStyle','-','linewidth',2);
set(H2,'LineStyle','-','linewidth',2);
label = strcat('KE_N_h_',R,'.eps')
print(owml,'-dpsc2',label);

else

keN = figure;
plot(sN2,'-b','linewidth',2);
title(strcat(['Brunt-Vaisala freq in Time (region ',R,', low-res)']),'fontsize',18);
xlabel('time (days)','fontsize',14)
ylabel('N^2 (s^{-2})','fontsize',14)
%ylim([0 270]);
label = strcat('Brunt_Vaisala_l_',R,'.eps')
print(keN,'-dpsc2',label);

skep = figure;
[AX H1 H2] = plotyy(1:itime,Ks,1:itime,K, 'plot')
set(get(AX(1),'Ylabel'),'String','KEs (m^2/s^2)','fontsize',12)
set(get(AX(2),'Ylabel'),'String','KE (m^2/s^2)','fontsize',12)

axes(AX(1));
%axis([2 itime+1 0 270]);
set(AX(1),'FontSize',12);
set(AX(1),'XTickLabel',[])

axes(AX(2));
%axis([2 itime+1 0 6*10^-3]);
xlabel('Time (days)','FontSize',12)
set(AX(2),'FontSize',14)

title(strcat(['KE below 33km and KE below 20km vs Time (region ',R,', low-res)']),'fontsize',16);
set(H1,'LineStyle','-','linewidth',2);
set(H2,'LineStyle','-','linewidth',2);
label = strcat('KE_KEs_l_',R,'.eps')
print(skep,'-dpsc2',label);


owml = figure;
[AX H1 H2] = plotyy(1:itime,sN2,1:itime,K, 'plot')
set(get(AX(1),'Ylabel'),'String','N^2 (s^{-2})','fontsize',12)
set(get(AX(2),'Ylabel'),'String','KE (m^2/s^2)','fontsize',12)

axes(AX(1));
%axis([2 itime+1 0 270]);
set(AX(1),'FontSize',12);
set(AX(1),'XTickLabel',[])

axes(AX(2));
%axis([2 itime+1 0 6*10^-3]);
xlabel('Time (days)','FontSize',12)
set(AX(2),'FontSize',14)

title(strcat(['KE and Mixed Layer Depth vs Time (region ',R,', low-res)']),'fontsize',16);
set(H1,'LineStyle','-','linewidth',2);
set(H2,'LineStyle','-','linewidth',2);
label = strcat('KE_N_l_',R,'.eps')
print(owml,'-dpsc2',label);

Ndiff = figure;
plot(TsN2-sN2,'-b','linewidth',2);
title(strcat(['Brunt-Vaisala freq difference in Time (region ',R,', high-res - low-res)']),'fontsize',18);
xlabel('time (days)','fontsize',14)
ylabel('N^2 (s^{-2})','fontsize',14)
%ylim([0 270]);
label = strcat('Brunt_Vaisala_diff_',R,'.eps')
print(Ndiff,'-dpsc2',label);


end

'saving...'
close all;

end % close archive low-res high-res
end % close region
