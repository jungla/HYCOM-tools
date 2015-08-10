function power = lomb(t,y,freq)
 nfreq = length(freq);
 fmax =  freq(nfreq);
 fmin =  freq(1);
 power = zeros(nfreq,1);
 f4pi = freq*4.*pi; pi2 = pi*2;
 n = length(y);
 cosarg = zeros(n,1);
 sinarg = zeros(n,1);
 argu = zeros(n,1);
 var = cov(y);
 
yn = y - mean(y);

for fi = 1:nfreq;
 sinsum = sum(sin(f4pi(fi)*t));
 cossum = sum(cos(f4pi(fi)*t));
 tau = atan2(sinsum,cossum);
 argu = pi2*freq(fi)*(t-tau);
 cosarg = cos(argu);
 cfi = sum(yn.*cosarg);
 cosnorm = sum(cosarg.*cosarg);
 sinarg = sin(argu);
 sfi = sum(yn.*sinarg);
 sinnorm = sum(sinarg.*sinarg);
 power(fi) = (cfi*cfi/cosnorm+sfi*sfi/sinnorm)/(2*var);
end
