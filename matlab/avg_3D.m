function average = avg_3D(input,pscx,pscy,fm,depth)
% computes average of a 3D matrix (tinput) over volume confined in x,y and depth
% used to compute averages over mixed layer depth

for did = 1:size(depth,1)-1
 dz(did) = depth(did+1)-depth(did);
end

jds = size(pscx,1);
ids = size(pscx,2);
kl = size(depth,1);

T = 0;
tt = 0;

for i = 1:jds
 for j = 1:ids
  for k = 1:kl-1
   if(~isnan(input(i,j,k)) && depth(k) <= fm(i,j))
     tt = tt + pscx(i,j)*pscy(i,j)*dz(k);
     T = T + input(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
   end
  end
 end
end

 if(tt > 0)
 average = T/tt
 end

