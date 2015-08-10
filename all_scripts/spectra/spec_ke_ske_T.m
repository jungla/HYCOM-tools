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

for region = 5:5

itime = 0;

[X1,X2,Y1,Y2,R] = regions(region);

 Nl = 30;
 M = size(text,1);

for arch = 1:2

 itime = 0;

for did =1:1

depth = readline('../layersDepth_4',did);
depthid = str2num(readline('../layersDepthID_4',did));
depth

for time = dayi:dstep:dayf-dstep

day   = textread('../archivesDay');
year  = textread('../archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);


 lday
 lyear

 itime = itime + 1;


clear p pf ket ke kea

% x bar for plotting
time(itime) = day;

pf = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Compute Spectra      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if (arch == 1)
  file = strcat('../energy/output/high-res/keenergy_h_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
 else
  file = strcat('../energy/output/low-res/keenergy_l_016_archv.',lyear,'_',lday,'_',depth,'_00.a');
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

% define lower limit

 ske  = sum(pf(f < 0.05 & f > 0.01)); % beteween 100km and 10km
 sske = sum(pf(f > 0.05));  % below 20km
 
 K(itime)  = ske;
 Ks(itime) = sske;

end % close day
end % close depth


skep = figure;
[AX H1 H2] = plotyy(1:itime,K,1:itime,Ks, 'plot')
set(get(AX(1),'Ylabel'),'String','KE (m^2/s^2)','fontsize',12)
set(get(AX(2),'Ylabel'),'String','KEs (m^2/s^2)','fontsize',12)
set(AX(1),'ycolor','k')
set(AX(2),'ycolor','b')
set(H1,'Color','k')
set(H2,'Color','b')

axes(AX(1));
set(AX(1),'FontSize',12);
set(AX(1),'XTickLabel',[])

axes(AX(2));
xlabel('Time (days)','FontSize',12)
set(AX(2),'FontSize',14)

if (arch == 1)
% title(strcat(['KE below 100km and KE below 10km vs Time (region ',R,', high-res)']),'fontsize',16);
 label = strcat('KE_KEs_h_',R,'.eps')
else
% title(strcat(['KE below 100km and KE below 10km vs Time (region ',R,', low-res)']),'fontsize',16);
 label = strcat('KE_KEs_l_',R,'.eps')
end

set(H1,'LineStyle','-','linewidth',2);
set(H2,'LineStyle','-','linewidth',2);
print(skep,'-dpsc2',label);

'saving...'
close all;

end % close archive low-res high-res
end % close region
