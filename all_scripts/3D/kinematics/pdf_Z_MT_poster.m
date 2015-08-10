clear; close all;

gridbfid = fopen('../../topo0.02/regional.grid.b','r');
line = fgetl(gridbfid);
idm  = sscanf(line,'%f',1);
line = fgetl(gridbfid);
jdm  = sscanf(line,'%f',1);
ijdm = idm*jdm;

file = '../../topo0.02/regional.grid.a';

lon = hycomread(file,idm,jdm,ijdm,1);
lat = hycomread(file,idm,jdm,ijdm,2);
pscx = hycomread(file,idm,jdm,ijdm,10);
pscy = hycomread(file,idm,jdm,ijdm,11);

day   = textread('../../archivesDay_all');
year  = textread('../../archivesYear_all');

maxv = 5;
minv = -5;

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);


for time  = 8:9

for arch = 1:2

ch = figure();

for did = 1:2:3

depth   = readline('../../3D/layersDepth_4',did);
depthid = str2num(readline('../../3D/layersDepthID_4',did));


% same days for all regions

 if (time == 8)
  daym = 199; % d 200 y 8
 else
  daym = 400; % d 35  y 9 
 end


clear ket ke kea p pf

nh = 0;
lti = -20;
lts =  20;

for t = lti:1:lts
   
R
lday   = digit(day(daym+t),3)
lyear  = digit(year(daym+t),4)
liday  = digit(day(daym),3);
liyear = digit(time,3);

if (arch == 1)
 file  = strcat('./output/high-res/vorticity_a_h_016_archv.',lyear,'_',lday,'_00.a');
else
 file  = strcat('./output/low-res/vorticity_a_l_016_archv.',lyear,'_',lday,'_00.a');
end

   tvort = binaryread(file,idm,jdm,ijdm,did);

   vort = tvort(Y1:Y2,X1:X2);
   vort = vort./(8*10^-5);
%   vort = smooth2(vort,1);
 if (t==lti)
  Tvort = reshape(vort,size(vort,1)*size(vort,2),1);
 else
  Tvort = [Tvort; reshape(vort,size(vort,1)*size(vort,2),1)];
 end

end % end of averaging in time loop


 TV = Tvort(~isnan(Tvort));

 [nh,xout] = hist(Tvort, [minv:(maxv-minv)/100:maxv]);

% TV = TV - mean(TV); 

 c = std(TV);
 
 nh = nh./sum(nh);

% nh = nh - mean(nh);

 minnh = min(nh(~isnan(nh)));

 l  = semilogy(xout,nh);

 hold on
   
 set(l,'linewidth',1.2)

if(did == 1)
 set(l,'LineStyle','-')
elseif(did == 3) 
 set(l,'LineStyle','--')
end 

 set(l,'Color','k');


% gaussian (only for HR surface)
% if (did == 1)
 a = 1/(c*sqrt(2*pi));
 y = a.*exp(-xout.^2/(2*c^2));
 y = y/sum(y);
  ls = semilogy(xout(xout >= -2 & xout <= 2),y(xout >= -2 & xout <= 2));

 set(ls,'linewidth',2)
% set(ls,'LineStyle','-')
 set(ls,'Color','r');

if(did == 1)
 set(ls,'LineStyle','-')
elseif(did == 3) 
 set(ls,'LineStyle','--')
end 
% end


end % close depth loop

%title(strcat(['Average spectra KE over max. Region ',R,', day ',liday,', year ',liyear, ' depth',depth]),'FontSize',14)
%legend('high-res','low-res');

xlabel('\zeta/f_0','FontSize',18);
ylabel('pdf','FontSize',18);

ylim([10^-6 1]);

if (time == 9)
 xlim([-4 +4])
else
 xlim([-3 +3])
end

set(gca,'FontSize',18);

% add lines
%x1 = [-1 -1];
%y1 = [minnh 1];

%x2 = [+1 +1];
%y2 = [minnh 1];

%line(x1, y1, 'LineStyle','.');
%line(x2, y2, 'LineStyle','.');

if(arch == 1)
 label = strcat('./plot/pdf_Z_M_h_poster_',liyear,'_',liday,'_',R,'.eps')
else
 label = strcat('./plot/pdf_Z_M_l_poster_',liyear,'_',liday,'_',R,'.eps')
end
'saving...'

print(ch,'-dpsc2',label)
close all;

end % close archive low-res high-res loop
%end % close day archive loop
end % close day archive loop
end % close day archive loop
