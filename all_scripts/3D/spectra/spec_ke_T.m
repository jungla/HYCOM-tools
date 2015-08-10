clear; close all;

gridbfid = fopen('/media/sdd1/hycom/scripts/topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
ijdm = idm*jdm;

file = '/media/sdd1/hycom/scripts/topo0.02/regional.grid.a';

pscx = hycomread(file,idm,jdm,ijdm,10);

dayi  = 1;    % variables for day loop
dayf  = 50;  %
dstep = 1;   %

for region = 1:4

[X1,X2,Y1,Y2,R] = regions(region);

for depthid = 1:10

depth = readline('/media/sdd1/hycom/scripts/3D/layersDepth_10',depthid);
depth

for time  = dayi:dstep:dayf-dstep

day   = textread('/media/sdd1/hycom/scripts/3D/archivesDay');
year  = textread('/media/sdd1/hycom/scripts/3D/archivesYear');

lday  = day_digit(day(time));
lyear = day_digit(year(time));

ch = figure();

for arch = 1:2

clear ket ke kea p pf

 pf = 0;

for t = -2:1:2 % each day is the time avarage of the spectra of five days.

   if (time > 2 && time < dayf-3)
    iday = day(time + t);
    iyear = year(time + t);
   else
    iday = day(time);
    iyear = year(time);
   end

    liday  = day_digit(iday)
    liyear = num2str(iyear);

 if (arch == 1)
  file = strcat('../energy/output/high-res/keenergy_h_016_archv.000',liyear,'_',liday,'_',depth,'_00.a');
 else
  file = strcat('../energy/output/low-res/keenergy_l_016_archv.000',liyear,'_',liday,'_',depth,'_00.a');
 end
    
 kea = hycomread(file,idm,jdm,ijdm,1);

 % it sums n spectra, taking nsp/ssp sections each ssp points.

 if(arch == 1)
  step = 1;
 else
  step = 4;
 end

[dx,ke,s,p,f,N] = spectrum_2D(X1,X2,Y1,Y2,kea,pscx,step);

pf = pf + p;

% print some diagnostics

 R
 t
 arch

end % end of averaging in time loop

 pf = pf./5;

  f = 1/(N*dx):1/(N*dx):1/(2*dx);
  l = loglog(f,pf,'-','linewidth',2);

 hold on
   
 set(l,'linewidth',[0.7])
 
 if(arch == 1)
  set(l,'Color','blue');
 elseif(arch == 2)
  set(l,'Color','black');
 elseif(arch == 3)
  set(l,'Color','green');
 elseif(arch == 4)
  set(l,'Color','red');
 end

end % close archive low-res high-res loop

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

label = strcat('./plot/spectra_ke_',lyear,'_',lday,'_',depth,'_',R,'.eps')
'saving...'

print(ch,'-dpsc2',label)
close all;

end % close day
end % close depth
end % close region
