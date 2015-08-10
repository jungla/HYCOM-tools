clear;
file = fopen('./particles-test.txt','w');

ox = 0;
oy = 0;
u = 0;
v = 0;

for i=1:10
    yr = randsample(20,1)+45;
    xr = randsample(20,1)+270;
    rtx = (randsample(100,1)/100-1);
    rty = (randsample(100,1)/100-1);
    
    o = randsample(15,1)/5;
    ol = randsample(10,1)/40;
    
    decay = randsample(10,1)/5;
    
    dt = 0.1;
    
    for t=0:dt:randsample(20,1)
        
    %o = o*exp(-t*decay/500);
    
    y = yr + sin(o*t) + t*rty + sin(ol*t);
    x = xr + cos(o*t) + t*rtx + cos(ol*t);
    
    if(t==0)
    ox = x;
    oy = y;
%    plot(x,y,'o');
    end
    
    u = (x-ox)/dt;
    v = (y-oy)/dt;
    
    oy = y;
    ox = x;
    
    
    plot(x,y);
%    quiver(x,y,u,v);
    
    hold on
    axis auto
    fprintf(file,'%6.4f\t',i);
    fprintf(file,'%6.4f\t',t);
    fprintf(file,'%6.4f\t',x);
    fprintf(file,'%6.4f\t',y);
    fprintf(file,'%6.4f\t','0');
    fprintf(file,'%6.4f\t','0');
    fprintf(file,'%6.4f\t',u);
    fprintf(file,'%6.4f\t',v);
%    fprintf(file,'%6.4f\t\n',o);
    end
end
