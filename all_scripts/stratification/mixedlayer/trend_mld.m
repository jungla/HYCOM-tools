clear all;
%%%% dimensions  
gridbfid=fopen('../../topo0.02/regional.grid.b','r');
line1 = fgetl(gridbfid);
idm  = sscanf(line1,'%f',1);
line1 = fgetl(gridbfid);
jdm  = sscanf(line1,'%f',1);

ijdm = idm*jdm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 
file = '../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

day   = textread('../../3D/archivesDay_all');
year  = textread('../../3D/archivesYear_all');

dayi = 1;
dayf = 498;
dstep = 1;

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

ml = figure();

for arch = 1:2

itime = 0;

for time  = dayi:dstep:dayf

lday  = digit(day(time),3)
lyear = digit(year(time),4)


% x bar for plotting
itime = itime + 1;

% x bar for plotting
timeBar(itime) = day(time);


 if(arch == 1)
  filer = strcat('../../../GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
 else
  filer = strcat('../../../GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
 end

 tTSR = hycomread(filer,idm,jdm,ijdm,6);

 tTSR = tTSR./9807;

 jds = X2-X1;
 ids = Y2-Y1;

 t = avg_region(tTSR,tpscx,tpscy,X1,X2,Y1,Y2,0);

 Q(itime) = t;

 end % day  loop

% plotting


%hold on;
%p = plot(Q);

 hold on;
 p1 = plot(Q);
 set(p1,'LineWidth',2);
 l = line([135 135],[0 300], 'Color', [0.5 0.5 0.5]);
 set(l,'LineWidth',2);


 if (arch == 1)
  set(p1,'Color','black');
 else
  set(p1,'Color','blue');
 end

end  % archive loop

% add vertical line
 
% hold on
  axis([1 itime 0 300]);
% line([135;  135],[35; 36]); 

 'plotting'

 set(gca, 'XTick', 1:30:itime);
 set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',24)

 xlabel('Time (days)','FontSize',30)
 ylabel('<MLD>','FontSize',30)
 label = strcat('mixlayer_',R,'.eps')
 print(ml,'-dpsc2',label);

close all;

end % region loop
