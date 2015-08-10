clear all;
close all;
%%%% dimensions  
gridbfid=fopen('/media/sdd1/hycom/GSa0.02/topo/regional.grid.b','r');
line=fgetl(gridbfid);
IDM=sscanf(line,'%f',1);
line=fgetl(gridbfid);
JDM=sscanf(line,'%f',1);
KDM=32;
R='GSa0.02'; 
E='016'; 
T='08';
Y='0008_062'
%subregion to be read: choose a subregion. Change to what is needed
%choose whole region
iif=1
iil=IDM
jjf=1
jjl=JDM
idm=iil-iif+1; jdm=jjl-jjf+1;kdm=KDM;
i1=iif; i2=iil; j1=jjf; j2=jjl


IJDM=IDM*JDM;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% field indices in the archv file minus 1 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 
npad=4096-mod(IJDM,4096);

grid_fid=fopen('/media/sdd1/hycom/GSa0.02/topo/regional.grid.a','r');

INDEX=1;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[lon,count]=fread(grid_fid,IJDM,'float32','ieee-be');


INDEX=2;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[lat,count]=fread(grid_fid,IJDM,'float32','ieee-be');


INDEX=10;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[pscx,count]=fread(grid_fid,IJDM,'float32','ieee-be');


INDEX=11;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[pscy,count]=fread(grid_fid,IJDM,'float32','ieee-be');

INDEX=12;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[plon,count]=fread(grid_fid,IJDM,'float32','ieee-be');


INDEX=13;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[plat,count]=fread(grid_fid,IJDM,'float32','ieee-be');




pscx = reshape(pscx,jdm,idm);
pscy = reshape(pscy,jdm,idm);
lon = reshape(lon,jdm,idm);
lat = reshape(lat,jdm,idm);
lon = lon(:,1);
lat = lat(1,:);
%lat = flipdim(lat,2);

lday = '';

for day=2:190
    
        lday = num2str(day);
       if(day < 100)
        lday = num2str(day);
        lday = strcat('0',lday);
        
        if(day < 10)
        lday = strcat('0',lday);
        end 
       end
    
    


file = strcat('/media/sdd1/hycom/GSa0.02/scripts/kinematics/okuboweiss/high-res/okuboweiss_h_016_archv.0008_',lday,'_00.a');
file1 = strcat('/media/sdd1/hycom/GSa0.02/scripts/stratification//mixlayer_h_016_archv.0008_',lday,'_00.a');
field = fopen(file,'r');
field1 = fopen(file1,'r');

INDEX = 1;
fseek(field,(INDEX-1)*4*(npad+IJDM),-1);
fseek(field1,(INDEX-1)*4*(npad+IJDM),-1);

[vort,count] = fread(field,IJDM,'float32','ieee-be');
[ml,count] = fread(field1,IJDM,'float32','ieee-be');

vort(vort > 2^10) = NaN;
ml(ml > 10^10) = NaN;

vort = vort/(8*10^-5);

plon = reshape(plon,IDM,JDM)';
plat = reshape(plat,IDM,JDM)';
vort = reshape(vort,IDM,JDM)';
ml = reshape(ml,IDM,JDM)';

%performing the division in cells...
gs = 200;
Q(1:157*107) = pi;
M(1:157*107) = pi;
mlg = zeros(jdm,idm);

t = 0;
m = 0;
ttt = 0;
mmm = 0;

%% calcualate the gradient of Mldepth

for i = 2:jdm-1
 for j = 2:idm-1
mlg(i,j) = (ml(i,j+1) - ml(i,j-1)) + (ml(i+1,j) - ml(i-1,j));
 end
end

% not the derivative
% mlg = ml;


%ml(:,1) = ml(:,2);
%ml(:,jdm) = ml(:,jdm-1);
%ml(1,:) = ml(2,:);
%ml(idm,:) = ml(idm-1,:);


%%% perform the division in cells
for j = 1:gs:idm-gs
 for i = 1:gs:jdm-gs
 % inner loop
 t = 0;
 tt = 0;
 
 m = 0;
 mm = 0;

 for x = 0:gs
  for y = 0:gs

   if( ~isnan(vort(i+x,j+y)) && ~isnan(mlg(i+x,j+y)) && vort(i+x,j+y) > 0)
%    t = t + vort(i+x,j+y);
    m = m + mlg(i+x,j+y);
    t = t + sqrt(vort(i+x,j+y))*(plon(i+x,j+y)*plat(i+x,j+y));
    tt = tt + plon(i+x,j+y)*plat(i+x,j+y);
    mm = mm + 1;
   end


  end
 end
 
 MQ(floor(i/gs)+1,floor(j/gs)+1) = t/tt;
 MM(floor(i/gs)+1,floor(j/gs)+1) = m/mm;
 

 if(mm > 0 && tt > 0)
 mmm = mmm + 1;
 Q(mmm) = t/tt;

 mmm = mmm + 1;
 M(mmm) = m/mm;
 end

 end
end




M = M(M ~= pi)/9806;
Q = Q(Q ~= pi);


'plotting...'
f1 = figure
scatter(M,Q)
title(strcat('OW and ML (cell size: ',num2str(gs),'). Day: ', num2str(lday)))
file = strcat('./plot/scatter_',gs,'_016_archv.0008_',lday,'_00.a');
label = strcat(file,'.eps');
print(f1,'-depsc2',label)



f2 = figure
imagesc(MQ)
title(strcat('OW and ML cell size: ',num2str(gs),'). Day: ', num2str(lday)))
file = strcat('./plot/ow_grid_',gs,'_016_archv.0008_',lday,'_00.a');
label = strcat(file,'.eps');
print(f2,'-depsc2',label)

f3 = figure
imagesc(MM)
title(strcat('OW and ML (cell size: ',num2str(gs),'). Day: ', num2str(lday)))
file = strcat('./plot/ml_grid_',gs,'_016_archv.0008_',lday,'_00.a');
label = strcat(file,'.eps');
print(f3,'-depsc2',label)


cf(day) = corr(reshape(M,size(M,2),1),reshape(Q,size(Q,2),1));
close all

%Q = flipdim(Q,1);
%[ch,ch]=contourf(vort,40);
%ch = figure();
%imagesc(lat,lon,Q);
%set(ch,'edgecolor','none');
%axis image;
%axis xy;
%load('MyColormaps','mycmap')
%set(ch,'Colormap',mycmap)

%title(['okuboweiss',' day:',lday]);
%colorbar
%caxis([-4*10^-5 4*10^-5])



%file = strcat('./',label,'_016_archv.0008_',lday,'_00.a');


%label = strcat(file,'.eps');
%'saving...'


%print(ch,'-depsc2',label)
%close(ch)
end

plot(cf)
