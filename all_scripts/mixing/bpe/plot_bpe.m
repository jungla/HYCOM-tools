clear all;

dat1 = load('pdf_A.dat');
dat2 = load('pdf_B.dat');
dat3 = load('pdf_C.dat');


days = 212;
bpe1(212) = 0.0;
bpe2(212) = 0.0;
bpe3(212) = 0.0;

for i=0:days

x1 = dat1(i*100+1:i*100+100,1);
y1 = dat1(i*100+1:i*100+100,2);
x2 = dat2(i*100+1:i*100+100,1);
y2 = dat2(i*100+1:i*100+100,2);
x3 = dat3(i*100+1:i*100+100,1);
y3 = dat3(i*100+1:i*100+100,2);

bpe1(i+1) = sum(y1.*x1);
bpe2(i+1) = sum(y2.*x2);
bpe3(i+1) = sum(y3.*x3);

end


f = figure;
hold on
f = plot(0:days,bpe1,'k')
f = plot(0:days,bpe2,'r')
f = plot(0:days,bpe3)
text(days+5,bpe1(days),'A')
text(days+5,bpe2(days),'B')
text(days+5,bpe3(days),'C')
%axis([0 3*10^5 23 27])
title('BPE in time (first 4 layers)');
xlabel('time')
ylabel('BPE')
saveas(f,'./plot/bpe_T.jpg','jpg')


