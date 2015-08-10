clear all;

dat = load('pdf_B.dat');

for i=0:190

y = dat(i*100+1:i*100+100,2);

[f] = plot(dat(i*100+1:i*100+100,1),y)
axis([0 3*10^5 23 27])
f = title(strcat('PDF - day: ',num2str(i)));
saveas(f,'./plot/pdf_A.jpg','jpg')
close
end
