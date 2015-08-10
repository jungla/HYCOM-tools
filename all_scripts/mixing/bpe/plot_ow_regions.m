%clear; close all;
%%%% dimensions  
gridbfid=fopen('regional.grid.b','r');
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

grid_fid=fopen('regional.grid.a','r');

INDEX=3;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[lon,count]=fread(grid_fid,IJDM,'float32','ieee-be');


INDEX=4;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[lat,count]=fread(grid_fid,IJDM,'float32','ieee-be');

INDEX=11;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[pscx,count]=fread(grid_fid,IJDM,'float32','ieee-be');


INDEX=12;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[pscy,count]=fread(grid_fid,IJDM,'float32','ieee-be');


pscx = reshape(pscx,jdm,idm);
pscy = reshape(pscy,jdm,idm);
pscx = pscx(:,1);
pscy = pscy(1,:);

lon = reshape(lon,jdm,idm);
lat = reshape(lat,jdm,idm);
lon = lon(:,1);
lat = lat(1,:);
%lat = flipdim(lat,2);

lday = '';
dend = 140
dbegin = 20;
obw(dend,3) = 0.0;

for day=dbegin:dend
    
        lday = num2str(day);
        if(day < 100)
        lday = num2str(day);
        lday = strcat('0',lday);
        
        if(day < 10)
        lday = strcat('0',lday);
        end 
        end
    
    

label = 'okuboweiss'

file = strcat('/media/sdd1/hycom/GSa0.02/scripts/kinematics/okuboweiss/high-res/',label,'_h_016_archv.0008_',lday,'_00.a');
field=fopen(file,'r');

file

INDEX=1;
fseek(field,(INDEX-1)*4*(npad+IJDM),-1);
[vort,count]=fread(field,IJDM,'float32','ieee-be');
vort(vort>10^10) = NaN;
vort = vort/(8*10^-5);
vort=reshape(vort,IDM,JDM)';

%% compute ow+ for the three regions...

for r=1:3
r
if (r==1)
% Region A
 x1 = round(3.0/8.0*idm);
 x2 = round(5.0/8.0*idm);
 y1 = round(3.0/8.0*jdm);
 y2 = round(5.0/8.0*jdm);
end
 
if (r==2)
% Region B
 x1 = round(3.0/4.0*idm) -10;
 x2 = idm -10;
 y1 = round(3.0/4.0*jdm) -10;
 y2 = jdm -10;
end

if (r==3)
% Region C
 x1 = round(3.0/4.0*idm) -10;
 x2 = idm -10;
 y1 = 10;
 y2 = round(jdm/4.0) + 10;
end

% define sub OW

v = vort(y1:y2,x1:x2);

ow = v(v>0);

ow = ow(ow~=0);

%compute owp

owp(day,r) = sum(sqrt(ow))/(sum(pscx)*sum(pscy));


end
end

'plotting...'

ch = figure();
hold on
plot(owp(:,1),'r')
plot(owp(:,2),'k')
plot(owp(:,3))
text(dend+2,owp(end,1),'A')
text(dend+2,owp(end,2),'B')
text(dend+2,owp(end,3),'C')

title('Positive part of Okuboweiss in time (3 regions). Only layer 4.');
xlabel('time')
ylabel('Positive OW in time normalized in space')
label = strcat('./plot/ow-time.jpg');
'saving...'


print(ch,'-djpeg',label)
close(ch)

f = figure;
scatter(reshape(bpe1(dbegin:dend),dend-dbegin+1,1),owp(dbegin:dend,1))
title('Correlation between OW+ and BPE, region A')
xlabel('OW+')
ylabel('BPE')

print(f,'-djpeg','./plot/corr_A.jpg')
close(f)

f = figure;
scatter(reshape(bpe2(dbegin:dend),dend-dbegin+1,1),owp(dbegin:dend,2))
title('Correlation between OW+ and BPE, region B')
xlabel('OW+')
ylabel('BPE')

print(f,'-djpeg','./plot/corr_B.jpg')
close(f)

f = figure;
scatter(reshape(bpe3(dbegin:dend),dend-dbegin+1,1),owp(dbegin:dend,3))
title('Correlation between OW+ and BPE, region C')
xlabel('OW+')
ylabel('BPE')

print(f,'-djpeg','./plot/corr_C.jpg')
close(f)
