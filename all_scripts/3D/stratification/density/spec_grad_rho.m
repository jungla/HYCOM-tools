clear; close all;

gridbfid = fopen('../../../topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
ijdm = idm*jdm;

file = '../../../topo0.02/regional.grid.a';

lon = hycomread(file,idm,jdm,ijdm,1);
lat = hycomread(file,idm,jdm,ijdm,2);
pscx = hycomread(file,idm,jdm,ijdm,10);
pscy = hycomread(file,idm,jdm,ijdm,11);

day   = textread('../../../archivesDay_all');
year  = textread('../../../archivesYear_all');

for region = 5:5

for arch = 1:2

ch = figure();


for time  = 8:9

for did = 1:2

depth = readline('../../layersDepth_4',did);
depthid = str2num(readline('../../layersDepthID_4',did));
depth

[X1,X2,Y1,Y2,R] = regions(region);

% select day according to the region

%if ((R == 'A') || (R == 'B'))
% if (time == 8)
% daym = 38; % d 200 y 8
% else
% daym = 40; % d 35 y 9 
% end
%else
% if (time == 8)
% daym = 38; % d 200 y 8
% else
% daym = 40; % d 35  y 9 
% end
%end

% same days for all regions

 if (time == 8)
  daym = 199; % d 200 y 8
 else
  daym = 400; % d 35  y 9 
 end


clear rhot rho rhoa p pf

pf = 0;
lti = -15;
lts = 15;

for t = lti:1:lts
   
lday   = digit(day(daym+t),3);
lyear  = digit(year(daym+t),4);
liday  = digit(day(daym),3)
liyear = digit(time,3)

 if (arch == 1)
  file = strcat('../../../../GSa0.02_3Da/016_archv.',lyear,'_',lday,'_00_3zr.A')
 else
  file = strcat('../../../../GSa0.08_3Da/archv.',lyear,'_',lday,'_00_3zr.A');
 end
    
 rhoa = binaryread(file,idm,jdm,ijdm,did);
% rhoa = smooth2(rhoa,2);
 [gRx,gRy] = gradient(rhoa,lon,lat);
 gradrhoa = sqrt(gRx.^2 + gRy.^2);

 % it sums n spectra, taking nsp/ssp sections each ssp points.

 spscx = 0;

 if(arch == 1)
  step = 1;
 else
  step = 4;
 end

[dx,rho,s,p,f,N] = spectrum_2D(X1,X2,Y1,Y2,gradrhoa,pscx,step);

pf = pf + p;

% print some diagnostics

 R
 t
 arch

end % end of averaging in time loop

'length' 
 length(lti:t)

 pf = pf./length(lti:t);

  f = 1/(N*dx):1/(N*dx):1/(2*dx);
  l = loglog(f,pf);

 hold on
   
 set(l,'linewidth',2)

 if(did == 1)
  set(l,'LineStyle','-')
 else
  set(l,'LineStyle','--')
 end

 if(time == 8)
  set(l,'Color','blue');
 else 
  set(l,'Color','black');
 end

end % close depth loop
end % close season

%title(strcat(['Average spectra KE over max. Region ',R,', day ',liday,', year ',liyear, ' depth',depth]),'FontSize',14)
%legend('high-res','low-res');

xlabel('K (km^{-1})','FontSize',30);
ylabel('\nabla\rho','FontSize',30);

%set(gca,'XTick', [10e-4 10e-3 10e-2 10e-1 1]);
%set(gca,'XTickLabel', [10e-4 10e-3 10e-2 10e-1 1],'FontSize',24);
set(gca,'FontSize',24);

ylim([10^-4 1])
xlim([5*10^-4 1])

%grid on

%x = -5:0.01:-1;
%r1 = plot(exp(x(300:end)),exp(x(300:end)*-3 -7),'r-.','linewidth',2);
%r2 = plot(exp(x(150:300)),exp(x(150:300)*-5/3 -7),'r-.','linewidth',2);
%text(4*10^-2,0.5,'-5/3','Color','r','fontsize',24);
%text(1.5*10^-1,0.5,'-3','Color','r','fontsize',24);

if (arch==1)
 label = strcat('./plot/spectra_grad_rho_h_',R,'.eps')
else
 label = strcat('./plot/spectra_grad_rho_l_',R,'.eps')
end

'saving...'

print(ch,'-dpsc2',label)
close all;

end % close archive low-res high-res loop
%end % close day archive loop
end % close region
