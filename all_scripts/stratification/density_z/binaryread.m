function array = binaryread(filename,IDM,JDM,IJDM,INDEX)

field=fopen(filename,'r');
fseek(field,(INDEX-1)*4*(IJDM),-1);
[array,count] = fread(field,IJDM,'float32','ieee-be');
fclose(field);

array(array > 10^10) = NaN;
array = reshape(array,IDM,JDM)';
