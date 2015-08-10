% compute averages of a matrix (input) over area (grid)

function average = avg_region(tinput,tpscx,tpscy,X1,X2,Y1,Y2,id)

pscx  = tpscx(Y1:Y2,X1:X2);
pscy  = tpscy(Y1:Y2,X1:X2);
input = tinput(Y1:Y2,X1:X2);

jds = X2-X1+1;
ids = Y2-Y1+1;

t  = 0;
tt = 0;

if (id == 0)

 for i = 1:ids
  for j = 1:jds
    if(~isnan(input(i,j)))
     t = t + input(i,j)*pscx(i,j)*pscy(i,j);
     tt = tt + pscx(i,j)*pscy(i,j);
    end
  end
 end

 if (tt > 0)
  average = t/tt;
 end

elseif (id == 1)

  for i = 1:ids
   for j = 1:jds
    if(~isnan(input(i,j)))
     t = t + input(i,j)*pscx(i,j)*pscy(i,j);
     tt = tt + pscx(i,j)*pscy(i,j);
    end
   end
  if (tt > 0)
   average(i) = t/tt;
  end
  end


elseif (id == 2)

  for j = 1:jds
   for i = 1:ids
    if(~isnan(input(i,j)))
     t = t + input(i,j)*pscx(i,j)*pscy(i,j);
     tt = tt + pscx(i,j)*pscy(i,j);
    end
   end
  if (tt > 0)
   average(j) = t/tt;
  end
 end


end
