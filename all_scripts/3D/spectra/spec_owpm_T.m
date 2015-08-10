clear; close all;
%%%% dimensions  
gridbfid=fopen('../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
IDM=sscanf(line,'%f',1);
line=fgetl(gridbfid);
JDM=sscanf(line,'%f',1);
iif=1;
iil=IDM;
jjf=1;
jjl=JDM;
idm=iil-iif+1; jdm=jjl-jjf+1;
i1=iif; i2=iil; j1=jjf; j2=jjl;


IJDM=IDM*JDM;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% field indices in the archv file minus 1 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../topo0.02/regional.grid.a';

lon = hycomread(file,IJDM,1);
lat  = hycomread(file,IJDM,2);
pscx = hycomread(file,IJDM,10);
pscy = hycomread(file,IJDM,11);

lon = reshape(lon,jdm,idm);
lat = reshape(lat,jdm,idm);
pscx = reshape(pscx,jdm,idm);
pscy = reshape(pscy,jdm,idm);

lon = lon(:,1);
lat = lat(1,:);

c   = 0;
omp = 0;

dayi = 1;    % variables for day loop
dayf = 366;  %
dstep = 10;  %


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
  X2 = 766
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

for arch = 1:2
for apm   = 1:2

 lyear = num2str(year);
 lday = num2str(day);

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
    
 owa = hycomread(file,IJDM,1);

 owa = reshape(owa,IDM,JDM)';


 % fill a vector with vort squared taking values over a straight line.
 % first, grid points are not a good measure of lenght. lenght shoulg be
 % expressend in meters...

 % it sums n spectra, taking nsp/ssp sections each ssp points.

 spscx = 0;

 nsp = 190;
 ssp = 5;

 my = 472;
 My = 839;

 x = 77;

 owt = zeros(1,My-my+1);

 for i=my:My
  s = 0;
  tpscx = 0;
  for j = 0:ssp:nsp
  if(~isnan(sum(owa(x+j,my:My))))
   s = s+1;
   owt(i-my+1) = owt(i-my+1) + owa(x+j,i);
   tpscx = tpscx + pscx(x+j,i);
  end
  end
  ow(i-my+1) = owt(i-my+1)./s;
  spscx = spscx + tpscx/s;
 end
  dx = spscx/((My-my+1)*1000); % also convert from m to km

 % for positive and negative part only...

 owp = NaN(1,1);
 owm = NaN(1,1);

 ii = 0;
 jj = 0;
 tm = 0;
 tp = 0;

 for i = 1:size(ow,2); 
  if (ow(i) > 0)
   ii = ii + 1;
   owp(ii) = ow(i);
   tp(ii) = i;
  else
   jj = jj + 1;
   owm(jj) = ow(i);
   tm(jj) = i;
  end
 end

 % quikly print owp and owm

 ch = figure();
 plot(ow);
 print(ch,'-dpsc2',strcat('./plot/ow_',lday,'_',lyear,'_',R,'.eps'))
 close;

 % N has to be multiple of 8 for the script to work

 if (mod(length(ow),2) ~= 0)
  N = length(ow) - 1;
 else
  N = length(ow);
 end

 if (arch == 1)
  nfft  = N-1;
  fs = 1;
 else
  nfft  = N/4-1;
  fs = 1/4
 end

 novlp = nfft-round(nfft/20);
 wind  = novlp+round(nfft/20);

% LOMB(T,H,OFAC,HIFAC) computes the Lomb normalized periodogram (spectral
% power as a function of frequency) of a sequence of N data points H,
% sampled at times T, which are not necessarily evenly spaced. T and H must
% be vectors of equal size. The routine will calculate the spectral power
% for an increasing sequence of frequencies (in reciprocal units of the
% time array T) up to HIFAC times the average Nyquist frequency, with an
% oversampling factor of OFAC (typically >= 4).
% 
% The returned values are arrays of frequencies considered (f), the
% associated spectral power (P) and estimated significance of the power
% values (prob).

 tp = tp';
 tm = tm';
 [pp,fp,probp] = lomb(tp,owp,4,0.5);
 [pm,fm,probm] = lomb(tm,owm,4,0.5);

% compute section length length in km.

% pf = sqrt(p(:,1)) + pf;
 
% print some diagnostics
 t
 arch

end % end of averaging in time llop

 pf = pf./5;

 ch = figure();

 if (arch == 1)
  k = 1/(N*dx):1/(N*dx):1/(2*dx);
  lp = plot(fp,pp,'-','linewidth',2);
  hold on;
  lm = plot(fm,pm,'-','linewidth',2);
 else
  k = 1/(N*dx):1/(N*dx):1/(8*dx);
  lp = plot(fp,pp,'-','linewidth',2);
  hold on;
  lm = plot(fm,pm,'-','linewidth',2);
 end
 
 hold on
   
%   set(l,'linewidth',[0.7])
 
     set(lp,'Color','blue');
     set(lm,'Color','black');

end % close archive low-res high-res loop


lday = num2str(str2num(lday) - 2); % since it is an average, the day is the center day of the 5 archives...

title(strcat(['Spectra OW (15 m) Region A, day ',lday,', year ',lyear]),'FontSize',18)
legend('positive','negative');

xlabel('K (km^{-1})','FontSize',14);
ylabel('OW (s^{-1})','FontSize',14);

%ylim([10^-12 10^-8])

%x = -5:0.01:-1;
%r1 = plot(exp(x(200:end)),exp(x(200:end)*-3 -7),'-.','linewidth',2);
%r2 = plot(exp(x),exp(x*-5/3 -7),'-.','linewidth',2);
%text(2*10^-2,2,'-5/3','fontsize',14);
%text(1.5*10^-1,2,'-3','fontsize',14);

if(arch == 1)
label = strcat('./plot/spectra_owpm_',lday,'_',lyear,'_h_',R,'.eps');
else
label = strcat('./plot/spectra_owpm_',lday,'_',lyear,'_l_',R,'.eps');
end

'saving...'


print(ch,'-dpsc2',label)

end % end pm loop
end % close something...
end % close region archive loop
end % close year archive loop
end % close day archive loop
