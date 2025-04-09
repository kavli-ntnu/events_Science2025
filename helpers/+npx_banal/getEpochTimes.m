
function [epochStartTime, epochStopTime, Fs] = getEpochTimes(d,seshInd,exact)
    
if ~seshInd
    [~,startInd] = min(abs(d.tracking.t - d.sessions(1).startTime));
    [~,stopInd] = min(abs(d.tracking.t - d.sessions(numel(d.sessions)).endTime));
else
    [~,startInd] = min(abs(d.tracking.t - d.sessions(seshInd).startTime));
    [~,stopInd] = min(abs(d.tracking.t - d.sessions(seshInd).endTime));
end

Fs = mode(diff(d.tracking.t));

if ~exist('exact','var')
    exact = true;
end

if exact
    epochStartTime = d.tracking.t(startInd);
    epochStopTime = d.tracking.t(stopInd);
else
    epochStartTime = d.tracking.t(startInd + round(3/Fs));
    epochStopTime = d.tracking.t(stopInd - round(3/Fs));
end