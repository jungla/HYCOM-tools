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

file = strcat('../../GSa0.02/expt_01.6/data/forcing.precip.a');

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
ids = X2-X1+1;
jds = Y2-Y1+1;
time = 0;

for day  = 1:365
% daily averages
 time = time + 1 
 cm = zeros(4,ids*jds);
 for hour = 1:4
  ct = hycomread(file,idm,jdm,ijdm,(day-1)*4+hour);
 %ct = ct.*landt;
  c = ct(Y1:Y2,X1:X2);
  cm(hour,:) = c(~isnan(c));
 end % hour
 meanc(time) = mean(cm(~isnan(cm)));
end % day

% filtering

%windowSize = 10;
%meanc = filter(ones(1,windowSize)/windowSize,1,meanc);
%stdc = filter(ones(1,windowSize)/windowSize,1,stdc);

% I shift it to match the last 365 days of simulation.
% build labels

dayi = 1%498-365
dayf = 498


day   = textread('/tamay/mensa/hycom/scripts/archivesDay_all');

 itime = 0;

for t  = dayi:1:dayf
 itime = itime + 1
 timeBar(itime) = day(t);
end

% shift array
%temp = zeros(1,itime);
%temp(1:dayi) = meanc(end-dayi+1:end);
%temp(dayi+1:end) = meanc(1:end-dayi);

temp = zeros(1,itime);
temp(1:365) = meanc(1:365);
temp(366:end) = meanc(1:dayf-365);

meanc = temp;

'plotting...'
[ch] = figure;
%p1 = plot(1:time,meanc+stdc,'-b',1:time,meanc-stdc,'-b',1:time,meanc,'-k');
p1 = plot(1:itime,meanc,'-k');
set(p1,'LineWidth',0.7);
l = vline(135,'g');
set(l,'LineWidth',1.2);

ylabel('P','FontSize',21)
xlabel('Time (days)','FontSize',21)
xlim([1 itime])

set(gca,'XTick', 1:60:itime);
set(gca,'XTickLabel',timeBar(1:60:end),'FontSize',18)

fileo = strcat('./plot/trend_precip_',R,'.eps')
%title(['Wind stress region ',R]);
'saving...'
print(ch,'-dpsc2',fileo)
close all;

end % region
