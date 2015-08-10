clear; close all;

gridbfid = fopen('../../topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
ijdm = idm*jdm;

file = '../../topo0.02/regional.grid.a';

pscx = hycomread(file,idm,jdm,ijdm,10);
pscy = hycomread(file,idm,jdm,ijdm,11);

dayi  = 1;    % variables for day loop
dayf  = 499;  %
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

depth = readline('../layersDepth_4a',did);
depthid = str2num(readline('../layersDepthID_4a',did));
depth

for time = dayi:dstep:dayf

day   = textread('../archivesDay');
year  = textread('../archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

lday
lyear

itime = itime + 1;

clear p pf ket ke kea

% x bar for plotting
timeBar(itime) = day(itime);

pf = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Compute Spectra      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if (arch == 1)
  file = strcat('../energy/output/high-res/keenergy_h_016_archv.',lyear,'_',lday,'_00.a');
 else
  file = strcat('../energy/output/low-res/keenergy_l_016_archv.',lyear,'_',lday,'_00.a');
 end
    
 kea = binaryread(file,idm,jdm,ijdm,depthid);

% kea = smooth2(kea,1);

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

if (arch == 1)
 file   = strcat('../../Rd/output/high-res/rd_h_016_archv.',lyear,'_',lday,'_00.a')
else
 file   = strcat('../../Rd/output/low-res/rd_l_016_archv.',lyear,'_',lday,'_00.a')
end

Rdt   = binaryread(file,idm,jdm,ijdm,1);
%Rdt(abs(Rdt) > 1000) = quantile(Rdt(~isnan(Rdt)),0.5);
% Rd is actually Rd^2 and can be positive or negative...

Rdm = Rdt(Y1:Y2,X1:X2);
Rdm = abs(Rdm);
Rdm = sqrt(Rdm)./1000;
RdM = avg_region(Rdm,pscx,pscy,1,X2-X1+1,1,Y2-Y1+1,0);

% ske  = sum(pf(f < 1/(RdM*5) & f > 1/(30*5))); % between 150km and Rd_ML*5
 sske = sum(pf(f > 1/(RdM*5)));  % below Rd_ML*5
% ske  = sum(pf(f > 1/(30*5) & f > 1/(500*5))); % between 150km and Rd_ML*5
% sske = sum(pf(f < 1/(30*5)));  % below Rd_ML*5

if arch == 1
 Kh(itime) = sske;
else
 Kl(itime) = sske;
end

end % close day
end % close depth
end % close archive low-res high-res

skep = figure;
[AX H1 H2] = plotyy(1:itime,Kh,1:itime,Kl, 'plot')
set(get(AX(1),'Ylabel'),'String','sKE_{HR} (m^2/s^2)','fontsize',18)
set(get(AX(2),'Ylabel'),'String','sKE_{LR} (m^2/s^2)','fontsize',18)
set(AX(1),'ycolor','k')
set(AX(2),'ycolor','b')
set(H1,'Color','k')
set(H2,'Color','b')

axes(AX(1));
set(AX(1),'ylim',[0 4]);
set(AX(1),'FontSize',17);
set(AX(1),'XTickLabel',[])

axes(AX(2));
set(AX(2),'ylim',[0 4]);
set(AX(2),'XTick', 1:30:itime);
set(AX(2),'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

xlabel('Time (days)','FontSize',18)

% title(strcat(['KE below 100km and KE below 10km vs Time (region ',R,', high-res)']),'fontsize',16);
 label = strcat('KE_KEs_',R,'.eps')
% title(strcat(['KE below 100km and KE below 10km vs Time (region ',R,', low-res)']),'fontsize',16);

set(H1,'LineStyle','-','linewidth',2);
set(H2,'LineStyle','-','linewidth',2);
print(skep,'-dpsc2',label);

'saving...'
close all;

end % close region
