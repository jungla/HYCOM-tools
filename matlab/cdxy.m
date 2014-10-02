function out = cdxy(input,pscx,id) 
% Centerd difference differentiation 
% Differently from diff in Matlab, pscx(i) is the spacing between input(i) and input(i+1)
% id = 0 -> along x
% id = 1 -> along y

ids = size(pscx,2);
jds = size(pscx,1);
out = zeros(jds,ids);

if id == 0

 out(:,1) = (input(:,2)-input(:,1))./pscx(:,1);
 out(:,ids) = (input(:,ids)-input(:,ids-1))./pscx(:,ids);

 for i=2:ids-1
  out(:,i) = (input(:,i+1)-input(:,i-1))./(pscx(:,i)+pscx(:,i-1));
 end

elseif id == 1

 out(1,:) = (input(2,:)-input(1,:))./pscx(1,:);
 out(jds,:) = (input(jds,:)-input(jds-1,:))./pscx(jds,:);

 for j=2:jds-1
  out(j,:) = (input(j+1,:)-input(j-1,:))./(pscx(j,:)+pscx(j-1,:));
 end

end


return
