
% Extract within-session correlation scores (e.g. CC 1 vs 1) to masterMat.
%
%   USAGE
%       [dataOutput,labels] = addStability(dataOutput,labels,sessions)
%       dataOutput        masterMat array
%       labels            masterMat labels
%       sessions          cell array of session names
%
%   OUTPUT
%       dataOutput        masterMat array
%       labels            masterMat labels
%
% Written by BRK 2018

function [dataOutput,labels] = addStability(dataOutput,labels,sessions)

global hippoGlobe
raw = dataOutput;

for iSession = 1:numel(sessions)
    if ~ismember(sprintf('CC %d vs %d',iSession,iSession),labels)
        labels{end+1} = sprintf('CC %d vs %d',iSession,iSession);
    end
    
    clusterNums = unique(extract.cols(raw,labels,'cell num'),'stable');
    numTotalClusters = length(clusterNums);
    for iCluster = 1:numTotalClusters
%         display(sprintf('Cluster %d of %d',iCluster,numTotalClusters))
        folder = extract.cols(raw,labels,'folder','cell num',clusterNums{iCluster},'session',sessions{iSession});
        if isempty(folder)
            raw(strcmpi(raw(:,strcmpi('cell num',labels)),clusterNums{iCluster}), ...
                strcmpi(sprintf('CC %d vs %d',iSession,iSession),labels)) = {nan};
            continue
        end
        posAve = minions.loadPosClean(folder{1});
        spikes = minions.loadSpikes(raw,labels,clusterNums{iCluster},sessions{iSession});
        if isempty(spikes)
            raw(strcmpi(raw(:,strcmpi('cell num',labels)),clusterNums{iCluster}), ...
                strcmpi(sprintf('CC %d vs %d',iSession,iSession),labels)) = {nan};
            continue
        end
        [p1,s1] = minions.sessionBlocks(posAve,spikes,2,1);
        m1 = analyses.map(p1,s1,'smooth',hippoGlobe.smoothing,'binWidth',hippoGlobe.binWidth,'limits',hippoGlobe.mapLimits);
        map1 = m1.z;
        [p2,s2] = minions.sessionBlocks(posAve,spikes,2,2);
        m2 = analyses.map(p2,s2,'smooth',hippoGlobe.smoothing,'binWidth',hippoGlobe.binWidth,'limits',hippoGlobe.mapLimits);
        map2 = m2.z;
        if ~isempty(map1) && ~isempty(map2)
            cc = analyses.spatialCrossCorrelation(map1,map2);
        else
            cc = nan;
        end
        raw(strcmpi(raw(:,strcmpi('cell num',labels)),clusterNums{iCluster}),...
            strcmpi(sprintf('CC %d vs %d',iSession,iSession),labels)) = {cc};
    end
    
end

dataOutput = raw;