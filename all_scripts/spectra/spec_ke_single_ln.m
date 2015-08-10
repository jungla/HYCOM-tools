clear; close all;

gridbfid = fopen('/home/jmensa/hycom/GSa0.08/expt_01.4/data/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
ijdm = idm*jdm;

file = '/home/jmensa/hycom/GSa0.08/expt_01.4/data/regional.grid.a';

lon = hycomread(file,idm,jdm,ijdm,1);
lat = hycomread(file,idm,jdm,ijdm,2);
pscx = hycomread(file,idm,jdm,ijdm,10);
pscy = hycomread(file,idm,jdm,ijdm,11);

for region = 1:4


[X1,X2,Y1,Y2,R] = regions(region);

X1 = X1/4;
X2 = X2/4;
Y1 = Y1/4;
Y2 = Y2/4;

year = 8
day  = 3

ch = figure();

clear ket ke kea p pf

lyear = num2str(year);
lday  = day_digit(day);

 lday
 lyear

pf = 0;
 
 file = strcat('../energy/keenergy_h_016_archv.000',lyear,'_',lday,'_04_00.a');
    
 kea = hycomread(file,idm,jdm,ijdm,1);

 % it sums n spectra, taking nsp/ssp sections each ssp points.

 spscx = 0;
 step = 1;
 [dx,ke,s,pf,f,N] = spectrum_2D(X1,X2,Y1,Y2,kea,pscx,step);

% print some diagnostics

 R

  f = 1/(N*dx):1/(N*dx):1/(2*dx);
  l = loglog(f,pf,'-','linewidth',2);

 hold on
   
 set(l,'linewidth',[0.7])
 
  set(l,'Color','blue');

title(strcat(['Spectra KE (15 m) Region ',R,', day ',lday,', year ',lyear]),'FontSize',18)
legend('high-res','low-res');

xlabel('K (km^{-1})','FontSize',14);
ylabel('KE (m^2/s^2)','FontSize',14);

ylim([10^-6 10])

x = -5:0.01:-1;
r1 = plot(exp(x(200:end)),exp(x(200:end)*-3 -7),'-.','linewidth',2);
r2 = plot(exp(x),exp(x*-5/3 -7),'-.','linewidth',2);
text(2*10^-2,2,'-5/3','fontsize',14);
text(1.5*10^-1,2,'-3','fontsize',14);

label = strcat('./spectra_ke_',lyear,'_',lday,'_',R,'_ln.eps')
'saving...'

print(ch,'-dpsc2',label)
close all;

end % region loop
