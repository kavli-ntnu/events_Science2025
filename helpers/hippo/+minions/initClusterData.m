
% When running emperorPenguin, there may be a cluster missing (or containing 0 spikes).
% This function fills in the data structure for all clusters with appropriate placeholders,
% and sets the column order for the output from emperorPenguin.
%
%   USAGE
%       clusterData = minions.initClusterData(clusterData,folder,tetrode,cluster,iCluster,iFolder,expNum,include)
%       clusterData     structure for storing all data
%       folder          string indicating recording directory
%       tetrode         double indicating tetrode number
%       cluster         double indicating cluster number
%       iCluster        double indicating the cluster index
%       iFolder         double indicating the session index
%       expNum          double indicating the experiment index
%       include         structure indicating which measures to calculate
%
%   OUTPUT
%       clusterData     structure for storing all data
%
%   SEE ALSO
%       meta.emperorPenguin
%
% Written by BRK 2017

function clusterData = initClusterData(clusterData,folder,tetrode,cluster,iCluster,iFolder,expNum,include)

%% general
clusterData(iCluster,iFolder,expNum).folder = folder;
clusterData(iCluster,iFolder,expNum).tetrode = tetrode;
clusterData(iCluster,iFolder,expNum).cluster = cluster;
clusterData(iCluster,iFolder,expNum).rateMap = nan;
clusterData(iCluster,iFolder,expNum).countMap = nan;
clusterData(iCluster,iFolder,expNum).meanRate = 0;
clusterData(iCluster,iFolder,expNum).peakRate = 0;
clusterData(iCluster,iFolder,expNum).totalSpikes = 0;

%% quality
quality = minions.loadQualityInfo(folder,tetrode,cluster);
try
    [L_ratio isoDist] = calc.clusterInfo(folder,tetrode,cluster);
catch
    L_ratio = nan;
    isoDist = nan;
end
clusterData(iCluster,iFolder,expNum).quality = quality;
clusterData(iCluster,iFolder,expNum).L_ratio = L_ratio;
clusterData(iCluster,iFolder,expNum).isoDist = isoDist;

%% extras
if include.spikeWidth
    clusterData(iCluster,iFolder,expNum).spikeWidth = nan;
end
if include.sss
    clusterData(iCluster,iFolder,expNum).spatInfo = nan;
    clusterData(iCluster,iFolder,expNum).selectivity = nan;
    clusterData(iCluster,iFolder,expNum).sparsity = nan;
end   
if include.coherence
    clusterData(iCluster,iFolder,expNum).coherence = nan;
end  
if include.fields
    clusterData(iCluster,iFolder,expNum).fieldNum = nan;
    clusterData(iCluster,iFolder,expNum).fieldMean = nan;
    clusterData(iCluster,iFolder,expNum).fieldMax = nan;
    clusterData(iCluster,iFolder,expNum).COMx = nan;
    clusterData(iCluster,iFolder,expNum).COMy = nan;
    clusterData(iCluster,iFolder,expNum).border = nan;
end  
if include.grid
    clusterData(iCluster,iFolder,expNum).gridScore = nan;
    clusterData(iCluster,iFolder,expNum).gridSpacing = nan;
    clusterData(iCluster,iFolder,expNum).gridOrient1 = nan;
    clusterData(iCluster,iFolder,expNum).gridOrient2 = nan;
    clusterData(iCluster,iFolder,expNum).gridOrient3 = nan;
end
if include.HD
    clusterData(iCluster,iFolder,expNum).mvl = nan;
    clusterData(iCluster,iFolder,expNum).angle = nan;
end
if include.speed
    clusterData(iCluster,iFolder,expNum).speed = nan;
end
if include.theta
    clusterData(iCluster,iFolder,expNum).thetaSpikes = nan;
    clusterData(iCluster,iFolder,expNum).thetaLFP = nan;
end
if include.obj
    clusterData(iCluster,iFolder,expNum).rateRatioO1 = nan;
    clusterData(iCluster,iFolder,expNum).rateRatioO2 = nan;
    clusterData(iCluster,iFolder,expNum).ratePvalO1 = nan;
    clusterData(iCluster,iFolder,expNum).ratePvalO2 = nan;
    clusterData(iCluster,iFolder,expNum).ratePvalAll = nan;
    clusterData(iCluster,iFolder,expNum).timeRatioO1 = nan;
    clusterData(iCluster,iFolder,expNum).timeRatioO2 = nan;
    clusterData(iCluster,iFolder,expNum).timePvalO1 = nan;
    clusterData(iCluster,iFolder,expNum).timePvalO2 = nan;
    clusterData(iCluster,iFolder,expNum).timePvalAll = nan;
end
    