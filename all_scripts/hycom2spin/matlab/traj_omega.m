close; clear;
omega = '../Hiord_stats_spline_m/chunk30_omega.dat';
%cross = '../Hiord_stats_spline_m/chunk10_cross.dat';
trajs = '../Hiord_stats_spline_m/chunk30_trajs.dat';

fomega=load(omega);
%fcross=load(cross);
ftrajs=load(trajs);


%id=fomega(1,:);
%o=fomega(8,:);

id = 1; %# id trajectory
j = 1;  %# line

% need a loop to erase all 9999 from the trajs file...

ftrajs = ftrajs(ftrajs(:,1) ~= 9999,:,:,:,:);
fomega = fomega(fomega(:,8) ~= 9999,:,:,:,:);

lr = size(ftrajs,1);
% lj = ftrajs(lr,5);

% d = 0.25; %delta t sampling
% t0 = 0.38;

%% I have to define an image with n rows, one for each omega range, than I
% plot into each row with the next script...
% plot each chunck on each realtive omega...

one = 0;
two = 0;
three = 0;
four = 0;

lj = size(fomega,1);

for j=1:lj
    o = fomega(j,8);
    if(abs(fomega(j,5)) > 0)
        
    if ((o <= -0.498) && (o >= -0.502))
    one = one + 1;
    
    line1  = ftrajs(ftrajs(:,5) == j,:,:,:,:);
    lons1  = line1(:,1);
    lats1  = line1(:,2);
    lons1b = lons1(1);
    lats1b = lats1(1);

    %subplot(2,2,1);
    plot(lons1b,lats1b,'o')
    hold on
    %subplot(2,2,1);
    plot(lons1,lats1,'-')
    
    title(one)
    end
    
    
    end



end

hold off