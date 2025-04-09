
% Analyze spike rate and animal dwell time related to objects in the environment.
%
%   USAGE
%       [objRate objTime] = calc.objectAnalysis(map,objectLocations)
%       map                 structure from analyses.map
%       objectLocations     matrix indicating object zones (0 = no object, 1 = object 1, 2 = object 2)    
%
%   OUTPUT
%       objRate             1 x 5 vector: rate ratio O1, rate ratio O2, P val O1, P val O2, P val all objects
%       objTime             1 x 5 vector: time ratio O1, time ratio O2, P val O1, P val O2, P val all objects
%
%   SEE ALSO
%       analyses.map
%
% Written by BRK 2017

function [objRate objTime] = objectAnalysis(map,objectLocations)

rateMap = map.z;
occupancyMap = map.time;

%% object responses using rate maps
% bins occupied by objects
nBinsObj1 = sum(sum(objectLocations == 1));
nBinsObj2 = sum(sum(objectLocations == 2));
nBinsObjAll = nBinsObj1 + nBinsObj2;
logicObjAll = objectLocations > 0;
% rate in each object zone
rateObj1 = rateMap(objectLocations == 1);
rateObj2 = rateMap(objectLocations == 2);
rateObjAll = rateMap(logicObjAll);
% rate outside of object zones
rateNoObj = rateMap;
rateNoObj(logicObjAll) = NaN;
logicNoObj = rateNoObj > 0;
nBinsNoObj = sum(sum(logicNoObj));
rateNoObj = rateNoObj(rateNoObj > 0);
% test for object responses
objResponsesRateIncrease = nan(2,500);
objResponsesRatePval = nan(3,500);
if nBinsNoObj >= nBinsObjAll;
    for iTest = 1:500
        randInds = randi(nBinsNoObj,1,nBinsNoObj);
        compObj1 = rateNoObj(randInds(1:nBinsObj1));
        compObj2 = rateNoObj(randInds(1:nBinsObj2));
        compObjAll = rateNoObj(randInds(1:(nBinsObj1+nBinsObj2)));
        objResponsesRateIncrease(1,iTest) = nanmean(rateObj1)/nanmean(compObj1);
        objResponsesRateIncrease(2,iTest) = nanmean(rateObj2)/nanmean(compObj2);
        [~,objResponsesRatePval(1,iTest)] = ttest2(compObj1,rateObj1);
        [~,objResponsesRatePval(2,iTest)] = ttest2(compObj2,rateObj2);
        [~,objResponsesRatePval(3,iTest)] = ttest2(compObjAll,rateObjAll);
    end
end
objRate = [nanmean(objResponsesRateIncrease(1,:)) ...
    nanmean(objResponsesRateIncrease(2,:)) ...
    nanmean(objResponsesRatePval(1,:)) ...
    nanmean(objResponsesRatePval(2,:)) ...
    nanmean(objResponsesRatePval(3,:))];

%% object responses using occupancy maps
% bins occupied by objects
nBinsObj1 = sum(sum(objectLocations == 1));
nBinsObj2 = sum(sum(objectLocations == 2));
nBinsObjAll = nBinsObj1 + nBinsObj2;
logicObjAll = objectLocations > 0;
% time in each object zone
timeObj1 = occupancyMap(objectLocations == 1);
timeObj2 = occupancyMap(objectLocations == 2);
timeObjAll = occupancyMap(logicObjAll);
% time outside of object zones
timeNoObj = map.time;
timeNoObj(logicObjAll) = NaN;
logicNoObj = timeNoObj > 0;
nBinsNoObj = sum(sum(logicNoObj));
timeNoObj = timeNoObj(timeNoObj > 0);
% test for object responses
objResponsesTimeIncrease = nan(2,500);
objResponsesTimePval = nan(3,500);
if nBinsNoObj >= nBinsObjAll;
    for iTest = 1:500
        randInds = randi(nBinsNoObj,1,nBinsNoObj);
        compObj1 = timeNoObj(randInds(1:nBinsObj1));
        compObj2 = timeNoObj(randInds(1:nBinsObj2));
        compObjAll = timeNoObj(randInds(1:(nBinsObj1+nBinsObj2)));
        objResponsesTimeIncrease(1,iTest) = nanmean(timeObj1)/nanmean(compObj1);
        objResponsesTimeIncrease(2,iTest) = nanmean(timeObj2)/nanmean(compObj2);
        [~,objResponsesTimePval(1,iTest)] = ttest2(compObj1,timeObj1);
        [~,objResponsesTimePval(2,iTest)] = ttest2(compObj2,timeObj2);
        [~,objResponsesTimePval(3,iTest)] = ttest2(compObjAll,timeObjAll);
    end
end
objTime = [nanmean(objResponsesTimeIncrease(1,:)) ...
    nanmean(objResponsesTimeIncrease(2,:)) ...
    nanmean(objResponsesTimePval(1,:)) ...
    nanmean(objResponsesTimePval(2,:)) ...
    nanmean(objResponsesTimePval(3,:))];

