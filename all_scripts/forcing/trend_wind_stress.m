clear; close all;
%%%% dimensions  
gridbfid=fopen('../topo0.02/regional.grid.b','r');
line=fgetl(gridbfid);
idm=sscanf(line,'%f',1);
line=fgetl(gridbfid);
jdm=sscanf(line,'%f',1);
ijdm=idm*jdm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% field indices in the archv file minus 1 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file names etc - edit file name to change files 

file = '../topo0.02/regional.grid.a';
file1 = '../topo0.02/depth_GSa0.02_08.a';

lont = hycomread(file,idm,jdm,ijdm,1);
latt = hycomread(file,idm,jdm,ijdm,2);

lday = '';

filee = strcat('../../GSa0.02/expt_01.6/data/forcing.tauewd.a');
filen = strcat('../../GSa0.02/expt_01.6/data/forcing.taunwd.a');

time = 0;

% define topography

tml = hycomread(file1,idm,jdm,ijdm,1);

landt = zeros(jdm,idm);

for i = 1:idm
   for j = 1:jdm
        if(isnan(tml(j,i)))
        landt(j,i) = NaN;
        else
        landt(j,i) = 1;
        end
    end
end


for region = 5:5

[X1,X2,Y1,Y2,R] = regions(region);

lon = lont(1,X1:X2);
lat = latt(Y1:Y2,1);

land = landt(Y1:Y2,X1:X2);

time = 0;

for day  = 1:365
for hour = 1:4

time = time + 1

ut = hycomread(filee,idm,jdm,ijdm,time);
vt = hycomread(filen,idm,jdm,ijdm,time);
ut = ut.*landt;
vt = vt.*landt;

u = ut(Y1:Y2,X1:X2);
v = vt(Y1:Y2,X1:X2);

c = sqrt(u.^2 + v.^2);
c = c(~isnan(c));
meanc(time) = mean(c);
stdc(time)  = std(c);

end % hour
end % day

% filtering

windowSize = 10;
meanc = filter(ones(1,windowSize)/windowSize,1,meanc);
stdc = filter(ones(1,windowSize)/windowSize,1,stdc);

'plotting...'
[ch] = figure;
%p1 = plot(1:time,meanc+stdc,'-b',1:time,meanc-stdc,'-b',1:time,meanc,'-k');
p1 = plot(1:time,meanc,'-k');
set(p1,'LineWidth',0.7);

ylabel('Wind stress (|\tau|)','FontSize',18)
xlabel('Time (days)','FontSize',18)

set(gca,'XTick', 1:4*30:time);
set(gca,'XTickLabel',1:30:365,'FontSize',15)


fileo = strcat('./plot/trend_wndstr_',R,'.eps')
%title(['Wind stress region ',R]);
'saving...'
print(ch,'-dpsc2',fileo)
close all;

end % region
