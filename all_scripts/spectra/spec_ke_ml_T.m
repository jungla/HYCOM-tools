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

for region = 1:4

itime = 0;

[X1,X2,Y1,Y2,R] = regions(region);

for arch = 1:2

itime = 0;

clear p pf ket ke kea

for year = 8:9

for day  = dayi:dstep:dayf-dstep
 if ((year ~= 8) || (day > 3))
 if ((year == 9) && (day >= 130))
 break;
 end

% x bar for plotting
itime = itime + 1
time(itime) = day;

 lyear = num2str(year);

 lday  = day_digit(day);

 lday
 lyear

pf = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Compute ML        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if (arch == 1)
  file1 = strcat('~/hycom/scripts/stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.000',lyear,'_',lday,'_00.a');
 else
  file1 = strcat('~/hycom/scripts/stratification/mixedlayer/output/low-res/mixlayer_l_016_archv.000',lyear,'_',lday,'_00.a');
 end

 tml   = hycomread(file1,idm,jdm,ijdm,1);
 tml   = tml./9806;

 mlv = avg_region(tml,pscx,pscy,X1,X2,Y1,Y2,0);

 M(itime) = mlv;


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

 R
 arch


  f = 1/(N*dx):1/(N*dx):1/(2*dx);

 ske = sum(pf(f>0.033));
 
 K(itime) = ske;


end % close if day
end % close day
end % close year

if (arch == 1)

owml = figure;
[AX H1 H2] = plotyy(1:itime,M,1:itime,K, 'plot')
set(get(AX(1),'Ylabel'),'String','ML Depth (m)','fontsize',12)
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
label = strcat('KE_ML_h_',R,'.eps')
print(owml,'-dpsc2',label);

else

owml = figure;
[AX H1 H2] = plotyy(1:itime,M,1:itime,K, 'plot')
set(get(AX(1),'Ylabel'),'String','ML Depth (m)','fontsize',12)
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
label = strcat('KE_ML_l_',R,'.eps')
print(owml,'-dpsc2',label);

end

'saving...'
close all;

save(strcat('spec_ke_ml_',R,'_',num2str(arch),'.mat'));

end % close archive low-res high-res
end % close region
