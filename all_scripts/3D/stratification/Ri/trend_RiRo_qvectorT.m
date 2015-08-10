clear all;
%%%% dimensions  
gridbfid=fopen('../../../topo0.02/regional.grid.b','r');
line1=fgetl(gridbfid);
idm=sscanf(line1,'%f',1);
line1=fgetl(gridbfid);
jdm=sscanf(line1,'%f',1);
ijdm=idm*jdm;

file = '../../../topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

tplon = hycomread(file,idm,jdm,ijdm,12);
tplat = hycomread(file,idm,jdm,ijdm,13);

omega  = 7.2921150*10^-5;
f(:,:) = zeros(jdm,idm);
f(:,:) = 2*omega*sin(tlat(:,:)*pi/90);

for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 49;
dstep = 1;

owml = figure;

for did =1:1

depth   = readline('../../../3D/layersDepth_4',did);
depthid = str2num(readline('../../../3D/layersDepthID_4',did));

%miny =  100;
%maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;

for arch = 1:2

clear RoM RiM;

itime = 0;

for time  = dayi:dstep:dayf-dstep+1

day   = textread('../../../3D/archivesDay');
year  = textread('../../../3D/archivesYear');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;

% x bar for plotting
timeBar(itime) = day(time);

lday
lyear
depth

if (arch == 1)
 file0  = strcat('../../../3D/stratification/Ri/output/high-res/ri_h_016_archv.',lyear,'_',lday,'_00.a')
 file1  = strcat('../../../3D/kinematics/output/high-res/vorticity_a_h_016_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('../../../3D/qvector/output/high-res/qvectorx_h_016_archv.',lyear,'_',lday,'_00.a')
 file3  = strcat('../../../3D/qvector/output/high-res/qvectory_h_016_archv.',lyear,'_',lday,'_00.a')
else 
 file0  = strcat('../../../3D/qvector/output/low-res/qvectorx_l_016_archv.',lyear,'_',lday,'_00.a')
 file1  = strcat('../../../3D/qvector/output/low-res/qvectory_l_016_archv.',lyear,'_',lday,'_00.a')
 file2  = strcat('../../../3D/stratification/Ri/output/low-res/ri_l_016_archv.',lyear,'_',lday,'_00.a')
 file3  = strcat('../../../3D/kinematics/output/low-res/vorticity_a_l_016_archv.',lyear,'_',lday,'_00.a')
end

Rit   = binaryread(file0,idm,jdm,ijdm,depthid);
Vort  = binaryread(file1,idm,jdm,ijdm,depthid);
qxt   = binaryread(file2,idm,jdm,ijdm,depthid);
qyt   = binaryread(file3,idm,jdm,ijdm,depthid);

qx = qxt(Y1:Y2,X1:X2);
qy = qyt(Y1:Y2,X1:X2);

qc = abs(divergence(qx,qy)); %sqrt(qx.^2 + qy.^2);
qcM(itime) = mean(qc(~isnan(qc)));

Rot   = Vort./f;
% to make Ri reasonable... replace too big values!!
Rit(Rit > 200) = quantile(Rit(~isnan(Rit)),0.5);
But = Rit.*(Rot.^2);
Bum = avg_region(But,tpscx,tpscy,X1,X2,Y1,Y2,0);

BuM(itime) = Bum;

end % day loop

%%%% IF YOU WANT TO ADD LOW RES DEFINE ANOTHER VAR


figure(owml);

hold on

[AX H1 H2] = plotyy(1:itime,BuM,1:itime,qcM, 'plot')
set(get(AX(1),'Ylabel'),'String','Bu^2','fontsize',18)
set(get(AX(2),'Ylabel'),'String','<\nabla \cdot Q>','fontsize',18)
set(AX(1),'ycolor','g')
set(AX(2),'ycolor','r')
set(H1,'Color','g')
set(H2,'Color','r')

axes(AX(1));
set(AX(1),'XTick', 1:3:itime);
set(AX(1),'FontSize',17);
set(AX(1),'XTickLabel',[])

axes(AX(2));
set(AX(2),'XTick', 1:3:itime);
set(AX(2),'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)

xlabel('Time (days)','FontSize',18)

set(H1,'LineStyle','-','linewidth',2);
set(H2,'LineStyle','-','linewidth',2);

if (arch == 1)
 label = strcat('./plot/RiRo2_qvector_h_',R,'.eps')
else
 label = strcat('./plot/RiRo2_qvector_l_',R,'.eps')
end

print(owml,'-dpsc2',label);

end % close archive high/low res loop

end % depth loop
end  % region loop
