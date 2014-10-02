function [dx,ke,s,pf,f,N] = spectrum_2D(X1,X2,Y1,Y2,kea,pscx,step)

% this function takes as imput: X1,X2,Y1,Y2: the coordinates in points over which the sections are taken
%                               kea:         the Kinetic Energy source Matrix (bigger or equal than the input coordinates)
%                               pscx:        matrix grid spacing
%                               step:        subsampling freq

 spscx = 0;

 nsp = Y2-Y1+step;
 ssp = 4*step;

 mx = X1;
 Mx = X2;

 y = Y1;

 ket(1:(Mx/step-mx/step+1)) = 0;
 ii = 0;

% take slices of the domain

 for i=mx:step:Mx
  ii = ii + 1;
  s = 0;
  tpscx = 0;
  for j = 0:ssp:nsp
  if(~isnan(kea(y+j,i)))
   s = s+1;
   ket(ii) = ket(ii) + kea(y+j,i);
   tpscx = tpscx + sum(pscx(y+j,i:i+step-1));
  end
  end
  ke(ii) = ket(ii)./s;
  spscx = spscx + tpscx/s;
 end

 dx = spscx*step/((Mx-mx+1)*1000); % also convert from m to km

 if (mod(length(ke),2) ~= 0)
  N = length(ke) - 1;
 else
  N = length(ke);
 end

  nfft  = N-1;
  fs = 1;

% overlapping as a function of nfft

 novlp = nfft-round(nfft/20);
 wind  = novlp+round(nfft/20);

 [p,f] = spectrum(ke,nfft,novlp,wind,fs);
 pf = sqrt(p(:,1));
