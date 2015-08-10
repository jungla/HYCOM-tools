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

dayi = 2
dayf = 366


t = 0;
m = 0;
ttt = 0;
mmm = 1;
tt = 0;
mm = 0;

Q(1:dayi*dayf) = pi;
M(1:dayi*dayf) = pi;

for day=dayi:dayf
    
        lday = num2str(day);
       if(day < 100)
        lday = num2str(day);
        lday = strcat('0',lday);
        
        if(day < 10)
        lday = strcat('0',lday);
        end 
       end
    
day    


file = strcat('/media/sdd1/hycom/GSa0.02/scripts/kinematics/okuboweiss/high-res/okuboweiss_h_016_archv.0008_',lday,'_00.a');
file1 = strcat('/media/sdd1/hycom/GSa0.02/scripts/stratification/high-res/mixlayer_h_016_archv.0008_',lday,'_00.a');
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

m = 0;
t = 0;
tt = 0;
mm = 0;


for j = 1:idm
 for i = 1:jdm

   if( ~isnan(vort(i,j)) && ~isnan(ml(i,j)) && vort(i,j) > 0)
    m = m + ml(i,j)/9806;
    t = t + sqrt(vort(i,j))*(plon(i,j)*plat(i,j));
    tt = tt + plon(i,j)*plat(i,j);
    mm = mm + 1;
   end

 end
end 

 if(mm > 0 && tt > 0)
 Q(mmm) = t/tt;
 M(mmm) = m/mm;

 mmm = mmm + 1;
 end



close all

end

M = M(M ~= pi);
Q = Q(Q ~= pi);

figure;
title('Okubo Weiss (positive part avg in space) in time')
plot(Q)
figure;
title('Mixed Layer depth in time')
plot(M)
figure;
title('Okubo Weiss vs Mixed layer depth')
scatter(M,Q)
