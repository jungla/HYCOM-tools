%close; clear;
foutname = '../Hiord_stats_spline/chunk30_omega.dat'
ftitle=foutname;
flt=load(foutname)';

dims=size(flt);
id=flt(1,:);
omega=flt(8,:);

firstP=flt(3,1);                                % Id first point...
nparts=(flt(3,size(flt,2))-100000)/20 - 0.5;    % # parts...
omega = omega(abs(omega)<1);

x = -1:0.1:1 ;
hist(omega,x)