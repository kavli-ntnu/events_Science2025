
function [posT posX posY HD posZ] = getPos(d,seshInd,split)

% NB: seshInd is only used when split is a scalar

if numel(split) == 1
    [epochStartTime, epochStopTime, Fs] = npx_banal.getEpochTimes(d,seshInd);
    midpt = (epochStartTime + epochStopTime) / 2;
    switch split
        case 1
            epochStopTime = midpt;
        case 2
            epochStartTime = midpt;
    end
else
    epochStartTime = split(1);
    epochStopTime = split(2);
end

runInds = (d.tracking.t > epochStartTime) & (d.tracking.t < epochStopTime);
posT = d.tracking.t(runInds);
posX = d.tracking.x(runInds);
posY = d.tracking.y(runInds);
posZ = d.tracking.z(runInds);
HD = rad2deg(d.tracking.hd_azimuth(runInds));
% Fs = mode(diff(posT));
% maxTime = max(posT) + Fs;