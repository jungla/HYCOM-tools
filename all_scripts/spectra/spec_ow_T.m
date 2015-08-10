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
dstep = 10;   %

for region = 1:4

 if (region == 1)
  X1 = 472
  X2 = 839
  Y1 = 77
  Y2 = 267
  R = 'A'
 elseif (region == 2)
  X1 = 840
  X2 = 1279
  Y1 = 77
  Y2 = 267
  R = 'B'
 elseif (region == 3)
  X1 = 619
  X2 = 986
  Y1 = 774
  Y2 = 900
  R = 'C'
 else
  X1 = 472
  X2 = 768
  Y1 = 393
  Y2 = 584
  R = 'D'
 end
    

for year = 8:9

for day  = dayi:dstep:dayf-dstep
 if ((year ~= 8) || (day ~= 1))
 if ((year == 9) && (day >= 133))
 break;
 end

ch = figure();

for arch = 1:2

 clear p pf ke kea ket

 lyear = num2str(year);
 lday  = num2str(day);

 if(day < 100)
  lday = strcat('0',lday);
  if(day < 10)
   lday = strcat('0',lday);
  end
 end

 lday
 lyear

pf = 0;

for t = -2:1:2 % each day is the time avarage of the spectra of five days.

   if (day > 2 && day < dayf-2)
    iday = day + t;
   else
    iday = day;
   end

    lday  = num2str(iday);
    lyear = num2str(year);

    if (iday<100)
        lday=strcat('0',lday);
    end
    if (iday<10)
        lday=strcat('0',lday);
    end

 if (arch == 1)
  file = strcat('../kinematics/output/okuboweiss/high-res/okuboweiss_h_016_archv.000',lyear,'_',lday,'_00.a');
 else
  file = strcat('../kinematics/output/okuboweiss/low-res/okuboweiss_l_016_archv.000',lyear,'_',lday,'_00.a');
 end
    
 kea = hycomread(file,idm,jdm,ijdm,1);

 % it sums n spectra, taking nsp/ssp sections each ssp points.

 spscx = 0;

 nsp = Y2-Y1+1;
 ssp = 5;

 mx = X1;
 Mx = X2;

 y = Y1;

 ket(1:Mx-mx+1) = 0;
 
 for i=mx:Mx
  s = 0;
  tpscx = 0;
  for j = 0:ssp:nsp
  if(~isnan(sum(kea(mx:Mx,y+j))))
   s = s+1;
   ket(i-mx+1) = ket(i-mx+1) + kea(y+j,i);
   tpscx = tpscx + pscx(y+j,i);
  end
  end
  ke(i-mx+1) = ket(i-mx+1)./s;
  spscx = spscx + tpscx/s;
 end

 dx = spscx/((Mx-mx+1)*1000); % also convert from m to km

 if (mod(length(ke),2) ~= 0)
  N = length(ke) - 1;
 else
  N = length(ke);
 end

 if (arch == 1)
  nfft  = N-1;
  fs = 1;
 else
  nfft  = N/4-1;
  fs = 1/4;
 end

 novlp = nfft-round(nfft/20);
 wind  = novlp+round(nfft/20);

 [p,f] = spectrum(ke,nfft,novlp,wind,fs);
 pf = sqrt(p(:,1)) + pf;

% print some diagnostics

 R
 t
 arch
 
end % end of averaging in time loop
 
 
 pf = pf./5; % average of 5 days in time...
 
 if (arch == 1)
  f = 1/(N*dx):1/(N*dx):1/(2*dx);
  l = loglog(f,pf,'-','linewidth',2);
 else
  f = 1/(N*dx):1/(N*dx):1/(8*dx);
  l = loglog(f,pf,'-','linewidth',2);
 end
 
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


if (str2num(lday) < 2)
 lday = num2str(str2num(lday)); % since it is an average, the day is the center day of the 5 archives...
else
 lday = num2str(str2num(lday) - 2); % since it is an average, the day is the center day of the 5 archives...
end

if (str2num(lday) < 100)
 lday = strcat('0',lday);
end
if (str2num(lday) < 10)
 lday = strcat('0',lday);
end

title(strcat(['Spectra OW (15 m) Region A, day ',lday,', year ',lyear]),'FontSize',18)
legend('high-res','low-res');

xlabel('K (km^{-1})','FontSize',14);
ylabel('OW (s^{-1})','FontSize',14);

ylim([10^-12 10^-8])

%x = -5:0.01:-1;
%r1 = plot(exp(x(200:end)),exp(x(200:end)*-3 -7),'-.','linewidth',2);
%r2 = plot(exp(x),exp(x*-5/3 -7),'-.','linewidth',2);
%text(2*10^-2,2,'-5/3','fontsize',14);
%text(1.5*10^-1,2,'-3','fontsize',14);

label = strcat('./plot/spectra_ow_',lday,'_',lyear,'_',R,'.eps');
'saving...'

print(ch,'-dpsc2',label)
close all;

end % close something...
end % close region archive loop
end % close year archive loop
end % close day archive loop
