clear all;
%%%% dimensions  
gridbfid=fopen('/tamay/mensa/hycom/scripts/topo0.02/regional.grid.b','r');
line1=fgetl(gridbfid);
idm=sscanf(line1,'%f',1);
line1=fgetl(gridbfid);
jdm=sscanf(line1,'%f',1);
ijdm=idm*jdm;

file = '/tamay/mensa/hycom/scripts/topo0.02/regional.grid.a';

tlon = hycomread(file,idm,jdm,ijdm,1);
tlat = hycomread(file,idm,jdm,ijdm,2);

tpscx = hycomread(file,idm,jdm,ijdm,10);
tpscy = hycomread(file,idm,jdm,ijdm,11);

tplon = hycomread(file,idm,jdm,ijdm,12);
tplat = hycomread(file,idm,jdm,ijdm,13);

omega  = 7.2921150*10^-5;
f(:,:) = zeros(jdm,idm);
f(:,:) = 2*omega*sin(tlat(:,:)*pi/90);

kl = 41
klo = 16

for region = 5:5

[X1A,X2A,Y1A,Y2A,R] = regions(6);

idso = X2A-X1A+1;
jdso = Y2A-Y1A+1;
ijdso = idso*jdso;

[X1,X2,Y1,Y2,R] = regions(region);

ids = X2-X1+1;
jds = Y2-Y1+1;
ijds = ids*jds;

lon = tlon(1,X1:X2);
lat = tlat(Y1:Y2,1);

pscx = tpscx(Y1:Y2,X1:X2);
pscy = tpscy(Y1:Y2,X1:X2);

dayi  = 1;
dayf  = 49;
days = 1;

owml = figure;


%miny =  100;
%maxy = -100;

t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;

for arch = 1:2

for did = 1:kl-1
 depth_1 = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_all_02',did));
 depth_2 = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_all_02',did+1));
 dz(did) = depth_2-depth_1;
 depth(did) = depth_1;
end
 depth(kl) = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_all_02',kl));


for did = 1:klo-1
 depth_1 = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_all_03',did));
 depth_2 = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_all_03',did+1));
 dz_O(did) = depth_2-depth_1;
 depth_O(did) = depth_1;
end
 depth_O(klo) = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepth_all_03',klo));



itime = 0;

for time  = dayi:days:dayf

day   = textread('/tamay/mensa/hycom/scripts/3D/archivesDay_all_03');
year  = textread('/tamay/mensa/hycom/scripts/3D/archivesYear_all_03');

lday  = digit(day(time),3);
lyear = digit(year(time),4);

% x bar for plotting
itime = itime + 1;

% x bar for plotting
timeBar(itime) = day(time);

lday
lyear

if (arch == 1)
 filem = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/links/016_archv.',lyear,'_',lday,'_00.a');
else
 filem = strcat('/tamay/mensa/hycom/GSa0.02/expt_01.6/data/nest/archv.',lyear,'_',lday,'_00.a');
end

fmt = hycomread(filem,idm,jdm,ijdm,6);
fm = fmt(Y1:Y2,X1:X2)./9806;
fmo = fmt(Y1A:Y2A,X1A:X2A)./9806;

ML(itime) = avg_region(fm,pscx,pscy,1,ids,1,jds,0);

for did =1:kl

depthid= str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_all_02',did));

if (arch == 1)
 file0  = strcat('/tamay/mensa/hycom/scripts/3D/stratification/Ri/output/high-res/ri_h_02_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('/tamay/mensa/hycom/scripts/3D/kinematics/output/high-res/vorticity_h_02_archv.',lyear,'_',lday,'_00.a');
 file2  = strcat('/tamay/mensa/hycom/scripts/3D/qvector/output/high-res/qvectorx_h_02_archv.',lyear,'_',lday,'_00.a');
 file3  = strcat('/tamay/mensa/hycom/scripts/3D/qvector/output/high-res/qvectory_h_02_archv.',lyear,'_',lday,'_00.a');
 file4  = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_h_archv.',lyear,'_',lday,'_00_3zw.A');
else 
 file2  = strcat('/tamay/mensa/hycom/scripts/3D/qvector/output/low-res/qvectorx_l_02_archv.',lyear,'_',lday,'_00.a');
 file3  = strcat('/tamay/mensa/hycom/scripts/3D/qvector/output/low-res/qvectory_l_02_archv.',lyear,'_',lday,'_00.a');
 file0  = strcat('/tamay/mensa/hycom/scripts/3D/stratification/Ri/output/low-res/ri_l_02_archv.',lyear,'_',lday,'_00.a');
 file1  = strcat('/tamay/mensa/hycom/scripts/3D/kinematics/output/low-res/vorticity_l_02_archv.',lyear,'_',lday,'_00.a');
 file4  = strcat('/tamay/mensa/hycom/GSa0.0x_02/02_l_archv.',lyear,'_',lday,'_00_3zw.A');
end

Rit  = binaryread(file0,idm,jdm,ijdm,depthid);
Vort = binaryread(file1,idm,jdm,ijdm,depthid);
qxt  = binaryread(file2,idm,jdm,ijdm,depthid);
qyt  = binaryread(file3,idm,jdm,ijdm,depthid);
wt   = binaryread(file4,idm,jdm,ijdm,depthid);

w(:,:,did)  =  wt(Y1:Y2,X1:X2);
qx = qxt(Y1:Y2,X1:X2);
qy = qyt(Y1:Y2,X1:X2);

Fqt(:,:,did) = abs(divergence(pscx,pscy,qx,qy)); %sqrt(qx.^2 + qy.^2);

Rot   = Vort./f;
% to make Ri reasonable... replace too big values!!
Rimax = quantile(Rit(~isnan(Rit)),0.9);
Rit(Rit > Rimax) = quantile(Rit(~isnan(Rit)),0.5);
But(:,:,did) = 1./(1+Rit.*(Rot.^2));

end % depth loop

%% depth lool for Omega

for did = 1:klo

depthid = str2num(readline('/tamay/mensa/hycom/scripts/3D/layersDepthID_all_03',did));

if (arch == 1)
 file0   = strcat('/nethome/jmensa/scripts_hycom/3D/omega/output/high-res/O_a_h_',lyear,'_',lday,'_00.a');
else
 file0   = strcat('/nethome/jmensa/scripts_hycom/3D/omega/output/low-res/O_a_l_',lyear,'_',lday,'_00.a');
end

Oat(:,:,did) = binaryread(file0,idso,jdso,ijdso,depthid);

end % depth Omega

T = 0;
W = 0;
B = 0;
tt = 0;
mm = 0;
ww = 0;

for i = 1:jdso
 for j = 1:idso
  for k = 1:klo-1
   if(~isnan(Oat(i,j,k)) && depth_O(k) <= fmo(i,j))
     tt = tt + pscx(i,j)*pscy(i,j)*dz_O(k);
     T = T + abs(Oat(i,j,k))*(pscx(i,j)*pscy(i,j))*dz_O(k);
   end
  end
 end
end

 if(tt > 0)
 OaM(itime) = T/tt;
 end

for i = 1:jds
 for j = 1:ids
  for k = 1:kl-1
   if(~isnan(But(i,j,k)) && depth(k) <= fm(i,j))
     tt = tt + pscx(i,j)*pscy(i,j)*dz(k);
     T = T + But(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
   end
   if(~isnan(Fqt(i,j,k)) && depth(k) <= fm(i,j))
     mm = mm + pscx(i,j)*pscy(i,j)*dz(k);
     B = B + Fqt(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
   end
   if(~isnan(w(i,j,k)) && depth(k) <= fm(i,j))
     ww = ww + pscx(i,j)*pscy(i,j)*dz(k);
     W = W + w(i,j,k)*(pscx(i,j)*pscy(i,j))*dz(k);
   end
  end
 end
end

 if(tt > 0)
 BuM(itime) = T/tt;
 end

 if(mm > 0)
 FqM(itime) = B/mm;
 end

 if(ww > 0)
 WM(itime) = W/ww;
 end


end % day loop
%%%% IF YOU WANT TO ADD LOW RES DEFINE ANOTHER VAR

W = FqM.*ML.^2.*BuM;
Wn = W./max(W);

FqMn = FqM./max(FqM);
BuMn = BuM./max(BuM);
MLn = ML.^2./max(ML.^2);
OaMn = OaM./max(OaM);
WMn = WM./max(WM);

[ch] = figure();

hold on;

p1 = plot(dayi:days:dayf,FqMn);
set(p1,'Color',[0.5 0.5 0.5],'LineWidth',1.2)
p2 = plot(dayi:days:dayf,BuMn);
set(p2,'Color',[0.5 0.5 0.5],'LineWidth',1.2,'LineStyle','-.')
p3 = plot(dayi:days:dayf,MLn);
set(p3,'Color',[0.5 0.5 0.5],'LineWidth',1.2,'LineStyle','--')
p4 = plot(dayi:days:dayf,OaMn);
set(p4,'Color','b','LineWidth',1.2)
p5 = plot(dayi:days:dayf,Wn);
set(p5,'Color','r','LineWidth',1.2)
%p6 = plot(dayi:days:dayf,WMn);
%set(p6,'Color','b','LineWidth',1.2)

if (arch == 1)
 label = strcat('./plot/QHBu_h_',R,'.eps')
else
 label = strcat('./plot/QHBu_l_',R,'.eps')
end

xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:3:itime);
set(gca,'XTickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'],'FontSize',17)


print(ch,'-dpsc2',label);

end % close archive high/low res loop
end  % region loop
