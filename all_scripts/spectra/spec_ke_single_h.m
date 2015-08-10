clear; close all;

gridbfid = fopen('../topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
ijdm = idm*jdm;

file = '../topo0.02/regional.grid.a';

lon = hycomread(file,idm,jdm,ijdm,1);
lat = hycomread(file,idm,jdm,ijdm,2);
pscx = hycomread(file,idm,jdm,ijdm,10);
pscy = hycomread(file,idm,jdm,ijdm,11);

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

year = 8
day  = 3

ch = figure();

clear ket ke kea p pf

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

    liday  = num2str(day);
    lyear = num2str(year);

    if (day<100)
        liday=strcat('0',liday);
    end
    if (day<10)
        liday=strcat('0',liday);
    end

file = strcat('./keenergy_h_016_archv.000',lyear,'_',liday,'_04_00.a');

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
%  if(~isnan(sum(kea(mx:Mx,y+j))))
   s = s+1;
   ket(i-mx+1) = ket(i-mx+1) + kea(y+j,i);
   tpscx = tpscx + pscx(y+j,i);
%  end
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

  nfft  = N-1;
  fs = 1;

 novlp = nfft-round(nfft/20);
 wind  = novlp+round(nfft/20);

 [p,f] = spectrum(ke,nfft,novlp,wind,fs);
 pf = sqrt(p(:,1));

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

label = strcat('./spectra_ke_',lyear,'_',lday,'_',R,'_h.eps')
'saving...'

print(ch,'-dpsc2',label)
close all;

end % region loop
