% MISTAKE!!! check the time in the traj file... same traj have to start on
% the same time!... ouch it shouldn't make any difference.

close; clear;
omega = '../Hiord_stats_spline/chunk30_omega.dat';
cross = '../Hiord_stats_spline/chunk30_cross.dat';
trajs = '../Hiord_stats_spline/chunk30_trajs.dat';

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

%% plot each chunck on each realtive omega...
one = 0;
two = 0;
three = 0;
four = 0;
lj = size(fomega,1);

for j=50:100
    line1  = ftrajs(ftrajs(:,5) == j,:,:,:,:);
    lons1 = line1(:,1);
    lats1 = line1(:,2);
    hold on
    plot(lons1,lats1)
    title('trajectories')
end

hold off