clear; close all;
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

grid_fid=fopen('./regional.grid.a','r');

INDEX=3;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[lon,count]=fread(grid_fid,IJDM,'float32','ieee-be');


INDEX=4;
fseek(grid_fid,(INDEX-1)*4*(npad+IJDM),-1);
[lat,count]=fread(grid_fid,IJDM,'float32','ieee-be');

lon = reshape(lon,jdm,idm);
lat = reshape(lat,jdm,idm);
lon = lon(:,1);
lat = lat(1,:);
%lat = flipdim(lat,2);

lday = '';

for day=50:184
    
    lday = num2str(day);
    if(day < 100)
        
        lday = strcat('0',lday);
        
        if(day < 10)
        lday = strcat('0',lday);
        end
    end

for i=4:4
    
if(i==1)
    label = 'divergence'
end

if(i==2)
    label = 'shearing'
end

if(i==3)
    label = 'stretching'
end

if(i==4)
    label = 'vorticity'
end

file = strcat(label,'_h_016_archv.0008_',lday,'_00.a');
%file = strcat('vorticity_016_archv.0008_051_00.a');

field=fopen(file,'r');

INDEX=1;
fseek(field,(INDEX-1)*4*(npad+IJDM),-1);
[vort,count]=fread(field,IJDM,'float32','ieee-be');

vort(vort>10^10) = NaN;
vort=reshape(vort,IDM,JDM)';
vort = vort/(8*10^-5);

'plotting...'


%vort = flipdim(vort,1);
%[ch,ch]=contourf(vort,40);
[ch] = imagesc(lon,lat,vort);
%set(ch,'edgecolor','none');
axis image;
axis xy;

ch = title([label,' day:',lday]);
colorbar
caxis([-1 2])

label = strcat(file,'.jpg');
'saving...'


saveas(ch,label,'jpg')
%close
end
end
