clear all;

gridbfid=fopen('~/hycom/scripts/topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
ijdm = idm*jdm;

dmax = 1000;
dday = 1;

dayi = 1;    % variables for day loop
dayf = 366;  %
dstep = 1;   %

maxr = 0;
minr = 100;
maxN2 = -100;
minN2 = 100;

maxtr = -10;
mintr = 10;
maxtN2 = -10;
mintN2 = 10;

for r = 1:4

 if (r == 1)
  X1 = 472;
  X2 = 839;
  Y1 = 77;
  Y2 = 267;
  R = 'A';
 elseif (r == 2)
  X1 = 840;
  X2 = 1279;
  Y1 = 77;
  Y2 = 267;
  R = 'B';
 elseif (r == 3)
  X1 = 619;
  X2 = 986;
  Y1 = 774;
  Y2 = 900;
  R = 'C';
 else
  X1 = 472;
  X2 = 766;
  Y1 = 393;
  Y2 = 584;
  R = 'D';
 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first check overall max density and frequency to plot...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



 N = 30;
 M = size(text,1);

for arch = 1:2

for year = 8:9

for day  = dayi:dstep:dayf-dstep
 if ((year ~= 8) || (day ~= 1))
 if ((year == 9) && (day >= 133))
 break;
 end

 lyear = num2str(year);
 lday = num2str(day);

 if(day < 100)
  lday = strcat('0',lday);
  if(day < 10)
   lday = strcat('0',lday);
  end
 end

 lday
 lyear


clear r z N2

 if (arch == 1)
  text  = textread(strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/high-res/',R,'/density_s_h_016_archv.000',lyear,'_',lday,'_',R,'0_00.dat'));
 else
  text  = textread(strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/low-res/',R,'/density_s_l_016_archv.000',lyear,'_',lday,'_',R,'0_00.dat'));
 end

  z  = text(:,2); % depth
  r  = text(:,3); % density

% add a first point at z = 0.
  z(1) = 0;
  r(1) = r(2);

 gr0 = sum(z)*9.81/sum(z.*r); % g/r0 

 N2(1) = gr0*(r(2)-r(1))/(z(2)-z(1));
 
 N2(N) = gr0*(r(N)-r(N-1))/(z(N)-z(N-1));

 for j = 2:N-1
  N2(j) = gr0*(r(j+1)-r(j-1))/(z(j+1)-z(j-1));
 end

 % interpolation vectors
 zi = 0:1:dmax;
 ri = interp1(z,r,zi,'linear');
 N2i = interp1(z,N2,zi,'linear');  

 if (arch == 1)
  tri  = ri;
  tN2i = N2i;
 else
  maxtr  = max(maxtr,max(tri-ri));
  mintr  = min(mintr,min(tri-ri));
  maxtN2 = max(maxtN2,max(tN2i-N2i));
  mintN2 = min(mintN2,min(tN2i-N2i));
 end


 maxr = max(maxr,max(ri));
 minr = min(minr,min(r));
 maxN2 = max(maxN2,max(N2i));
 minN2 = min(minN2,min(N2i));

end % if
end % days
end % days
end % years

maxr
minr
maxN2
minN2

file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);


lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %          real computation
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first check overall max density and frequency to plot...

 
 itime = 0;


 N = 30;
 M = size(text,1);

for arch = 1:2

for year = 8:9

for day  = dayi:dstep:dayf-dstep
 if ((year ~= 8) || (day ~= 1))
 if ((year == 9) && (day >= 133))
 break;
 end

 lyear = num2str(year);
 lday = num2str(day);

 if(day < 100)
  lday = strcat('0',lday);
  if(day < 10)
   lday = strcat('0',lday);
  end
 end

 lday
 lyear

clear r z N2

 itime = itime + 1;


 if (arch == 1)
  text  = textread(strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/high-res/',R,'/density_s_h_016_archv.000',lyear,'_',lday,'_',R,'0_00.dat'));
 else
  text  = textread(strcat('/media/sdd1/hycom/scripts/stratification/density_z/output/low-res/',R,'/density_s_l_016_archv.000',lyear,'_',lday,'_',R,'0_00.dat'));
 end

  z  = text(:,2); % depth

% rebuild depth... this should GOGOGO!!!
 for n=2:N 
  z(n) = z(n) + z(n-1);
 end

  r  = text(:,3); % density

% add a first point at z = 0.
  z(1) = 0;
  r(1) = r(2);

 gr0 = sum(z)*9.81/sum(z.*r); % g/r0 

 N2(1) = gr0*(r(2)-r(1))/(z(2)-z(1));

 N2(N) = gr0*(r(N)-r(N-1))/(z(N)-z(N-1));

 for j = 2:N-1
  N2(j) = gr0*(r(j+1)-r(j-1))/(z(j+1)-z(j-1));
 end

 % interpolation vectors
 zi = 0:1:dmax;
 ri = interp1(z,r,zi,'linear');
 N2i = interp1(z,N2,zi,'linear');  
 
% save integrated N in time... I integrate over 300 m

 sN2(itime) = sum(N2i(zi < 300));

%%%%%%%%%%%%%%%%%%%%%%%%
% compute ML, for each day, for each resolution

% the date is messed up... i fix it.

 day = str2num(lday);

 
 if (arch == 1)
  file1 = strcat('~/hycom/scripts/stratification/mixedlayer/output/high-res/mixlayer_h_016_archv.000',lyear,'_',lday,'_00.a');
 else
  file1 = strcat('~/hycom/scripts/stratification/mixedlayer/output/low-res/mixlayer_l_016_archv.000',lyear,'_',lday,'_00.a');
 end

 tml = hycomread(file1,idm,jdm,ijdm,1);
 tml = tml./9806;

 mld = avg_region(tml,tpscx,tpscy,X1,X2,Y1,Y2,0)

%%%%%%%%%%%%%%%%%%%%%%% 
%% plot density and N2 ina single graph,
 
 [ch] = figure;

% the date is messed up... i fix it.

 if (arch == 1)

 tri = ri;
 tN2i = N2i;

 subplot(1,2,1);
 p1 = plot(r,z,'+',ri,zi,'linewidth',2);
 title(['\sigma and N^2 profiles (region ',R,', high res), day: ',lday,', year: ',lyear],'fontsize',15,  'Units', 'normalized', 'Position', [0.2 1],'HorizontalAlignment', 'left','VerticalAlignment','bottom');
 set(gca,'ydir','rev')
 axis([minr maxr 0 dmax])
 xlabel('Density (sigma units)','FontSize',14)
 ylabel('Depth (m)','FontSize',14)
 hold on;
 plot([minr maxr],[mld mld]);

 subplot(1,2,2);
 p2 = plot(N2,z,'+',N2i,zi,'linewidth',2);
 set(gca,'ydir','rev')
 xlim([minN2 maxN2])
 ylim([0 dmax])
 xlabel('Frequency (s^{-1})','FontSize',14)
 hold on;
 plot([minN2 maxN2],[mld mld]);

 label = strcat('/media/sdd1/hycom/scripts/stratification/density_z/plot/',num2str(dmax),'/high-res/density_z_',num2str(dmax),'_',lyear,'_',lday,'_h_',R,'0.eps')
 'saving...'
 print(ch,'-dpsc2',label)

 else

 subplot(1,2,1);
 p1 = plot(r,z,'+',ri,zi,'linewidth',2);
 title(['\sigma and N^2 profiles (region ',R,', low res), day: ',lday,', year: ',lyear],'fontsize',15,  'Units', 'normalized', 'Position', [0.2 1],'HorizontalAlignment', 'left','VerticalAlignment','bottom');
 set(gca,'ydir','rev')
 xlim([minr maxr])
 ylim([0 dmax])
 xlabel('Density (sigma units)','FontSize',14)
 ylabel('Depth (m)','FontSize',14)
 hold on;
 plot([minr maxr],[mld mld]);

 subplot(1,2,2);
 p2 = plot(N2,z,'+',N2i,zi,'linewidth',2);
 set(gca,'ydir','rev')
 xlim([minN2 maxN2])
 ylim([0 dmax])
 xlabel('Frequency (s^{-1})','FontSize',14)
 hold on;
 plot([minN2 maxN2],[mld mld]);

 label = strcat('/media/sdd1/hycom/scripts/stratification/density_z/plot/',num2str(dmax),'/low-res/density_z_',num2str(dmax),'_',lyear,'_',lday,'_l_',R,'0.eps')
 'saving...'
 print(ch,'-dpsc2',label)

 close;
 figure();
 %% plot differences...

% ri = interp1(z,tri-ri,zi,'linear');
% N2i = interp1(z,tN2-N2,zi,'linear');

 subplot(1,2,1);
% p1 = plot(tr-ri,z,'+',ri,zi,'linewidth',2);
 p1 = plot(tri-ri,zi,'linewidth',2);
 title(['\sigma_h - \sigma_l, N^2_h - N^2_l (region ',R,'), day: ',lday,', year: ',lyear],'fontsize',15,  'Units', 'normalized', 'Position', [0.2 1],'HorizontalAlignment', 'left','VerticalAlignment','bottom');

 set(gca,'ydir','rev')
 xlim([mintr maxtr])
 ylim([0 dmax])
 xlabel('Density (sigma units)','FontSize',14)
 ylabel('Depth (m)','FontSize',14)
 hold on;
 plot([minr maxr],[mld mld]);

 subplot(1,2,2);
% p2 = plot(tN2-N2,z,'+',N2i,zi,'linewidth',2);
 p2 = plot(tN2i-N2i,zi,'linewidth',2);
 set(gca,'ydir','rev')
 xlim([mintN2 maxtN2])
 ylim([0 dmax])
 xlabel('Frequency (s^{-1})','FontSize',14)
 hold on;
 plot([mintN2 maxtN2],[mld mld]);

 label = strcat('/media/sdd1/hycom/scripts/stratification/density_z/plot/',num2str(dmax),'/diff/density_z_',num2str(dmax),'_',lyear,'_',lday,'_diff_',R,'0.eps')
 'saving...'
 print(ch,'-dpsc2',label)

 close all;

 end 

end % end if
end % end day
end % end year

%save(strcat('sN2_',R,'_',num2str(arch),'.mat'), sN2);

end % end arch
end % end region
