
% Read fortran binary files usage is
% array = fortread(fid, IDN,JDM,M,N)
% where 
% M is the row size of the array
% N is the column size of the array
% fid is the fileid that is supposed to have been opened as binary.

function array = hycomread(filename,IDM,JDM,IJDM,INDEX)

npad=4096-mod(IJDM,4096);
field=fopen(filename,'r');
fseek(field,(INDEX-1)*4*(npad+IJDM),-1);
[array,count] = fread(field,IJDM,'float32','ieee-be');
fclose(field);
array(array > 10^8) = NaN;
array = reshape(array,IDM,JDM)';

