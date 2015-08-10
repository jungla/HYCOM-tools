clear; close all;

gridbfid = fopen('../topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
ijdm = idm*jdm;

file = '../topo0.02/regional.grid.a';

pscx = hycomread(file,idm,jdm,ijdm,10);

dayi  = 1;    % variables for day loop
dayf  = 366;  %
dstep = 1;   %

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

for year = 8:9

for day  = dayi:dstep:dayf-dstep
 if ((year ~= 8) || (day > 3))
 if ((year == 9) && (day >= 130))
 break;
 end

ch = figure();

for arch = 1:2

clear ket ke kea p pf

 lyear = num2str(year);
 lday  = day_digit(day);


 lday
 lyear

 pf = 0;

for t = -2:1:2 % each day is the time avarage of the spectra of five days.
   
   if (day > 2 && day < dayf-3)
    iday = day + t;
   else
    iday = day;
   end

    liday  = day_digit(iday)
    lyear = num2str(year);

 if (arch == 1)
  file = strcat('../energy/output/ke04/high-res/keenergy_h_016_archv.000',lyear,'_',liday,'_04_00.a');
 else
  file = strcat('../energy/output/ke04/low-res/keenergy_l_016_archv.000',lyear,'_',liday,'_04_00.a');
 end
    
 kea = hycomread(file,idm,jdm,ijdm,1);

 % it sums n spectra, taking nsp/ssp sections each ssp points.

 if(arch == 1)
  step = 1;
 else
  step = 4;
 end

[dx,ke,s,p,f,N] = spectrum_2D(X1,X2,Y1,Y2,kea,pscx,step);

ke

pf = pf + p;

% print some diagnostics

 R
 t
 arch

end % end of averaging in time llop


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

label = strcat('./plot/spectra_ke_',lyear,'_',lday,'_',R,'.eps')
'saving...'

print(ch,'-dpsc2',label)
close all;

end % close day archive loop
end % close day archive loop
end % close day archive loop
end % close day archive loop
