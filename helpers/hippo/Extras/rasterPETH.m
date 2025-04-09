
%Raster and PETH (Can be used by neuroscientist who are interested in Rate analysis and also other purposes), simple version, by Sisi Ma
% Input: 
    %event: timestamp of event interested in (eg. laser ON);   
    %spike: timestamp of spikes (or a second event) single col
    %pre: front edge of time window (how long before the first event you want for look at)
    %pos: back edge of time window (how long after the first event you
    %want to look at)
    
function [rast,eventWin]= rasterPETH(event,spike,pre,pos)

eventWin=[event(:,1)-pre event(:,1)+pos];
rast=[];
for i=1:length(eventWin)
    count=sum(spike<=eventWin(i,2))-sum(spike<=eventWin(i,1));
    if count~=0
        for j=1:count
             t=intersect(find(spike>=eventWin(i,1)),find(spike<=eventWin(i,2)));
             rast(end+1,1)=spike(t(j))-event(i,1); % when did the firing happen in respect to the start time of the movement
             rast(end,2)=i; % which movement does the firing relate with
             rast(end,3)=event(i,1);% time when up movement starts           
        end
    else %there is no firing during the up movement being assessed
         rast(end+1,1)=NaN;
         rast(end,2)=i;
         rast(end,3)=event(i,1);        
    end
end








