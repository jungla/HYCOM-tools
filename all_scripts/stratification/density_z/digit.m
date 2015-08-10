function lday = digit(day,n)
 
lday  = num2str(day);

while (length(lday) < n)
  lday = strcat('0',lday);
end
