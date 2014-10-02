function [M] = section_var(idm,jdm,x1,x2,y,nl,file,pll,var_id,id)
  % works in hybrid coordinates
  % extract an array with 4 columns and as many rows as points in the x direction times the number of layers
  % columns are for: layer #, layer depth, layer density, longitude/latitude
  % the quantity extracted is defined by var_id
  % id = 0, along x; id = 1, along y.

  ijdm = idm*jdm;
  xds = x2-x1+1;
  g = 0.000101978;

  Hlx = zeros(xds,nl);
  Tlx = zeros(xds,nl);

  if id == 0 
   ll   = pll(y,x1:x2);
  else
   ll   = pll(x1:x2,y);
  end

  Rt = 0.0;

  for k = 1:nl
   H(:,:) = hycomread(file,idm,jdm,ijdm,9+k*5);
   T(:,:) = hycomread(file,idm,jdm,ijdm,var_id+k*5);
   H(:,:) = H(:,:)*g;

   if id == 0
    for i = x1:x2
    ii = i-x1+1;

    if(H(y,i) > 0)
     Tlx(ii,k)   = T(y,i);
     Hlx(ii,k)   = H(y,i);
    else
     Tlx(ii,k)   = NaN;
     Hlx(ii,k)   = NaN;
    end
   else
    for i = x1:x2
    ii = i-x1+1;

    if(H(i,y) > 0)
     Tlx(ii,k)   = T(i,y);
     Hlx(ii,k)   = H(i,y);
    else
     Tlx(ii,k)   = NaN;
     Hlx(ii,k)   = NaN;
    end
   end

   end   % x-loop
  end    % layers

  for k=2:nl
   Hlx(:,k) = Hlx(:,k) + Hlx(:,k-1);               
  end

 M = zeros(k*ids,4);

 for k = 1:nl
  for i = 1:xds
   M(i+(k-1)*xds,1) = k;
   M(i+(k-1)*xds,2) = Hlx(i,k);
   M(i+(k-1)*xds,3) = Tlx(i,k);
   M(i+(k-1)*xds,4) = lon(i);
  end
 end

