
% Calculate L_ratio and isolation distance values outside of MClust.
%
%   USAGE
%       [L_ratio IsoD] = calc.clusterInfo(folder,tNum,cNum)
%       folder          string specifying where the data lives
%       tNum            double specifying the tetrode number
%       cNum            double specifying the cluster number
%
%   OUTPUTS
%       L_ratio         L_ratio
%       IsoD            isolation distance
%
% Written by BRK 2017

function [L_ratio IsoD] = clusterInfo(folder,tNum,cNum)

%% check inputs
global hippoGlobe
if ~strcmpi(hippoGlobe.clusterFormat,'MClust')
    error('This function currently only works for MClust clusters')
end
if (helpers.isstring(folder) + helpers.isdscalar(tNum) + helpers.isdscalar(cNum)) < 3
    error('Inputs must be 1 string and 2 doubles')
end

%% get filename
clusterList = dir(fullfile(folder,'*.t'));  
if ~isempty(strfind(clusterList(1).name,'PP')) && isempty(strfind(clusterList(1).name,'SS')) % norway MClust
    switch tNum
        case 1
            TTfn = 'PP4_TT1';
        case 2            
            TTfn = 'PP6_TT2';
        case 3            
            TTfn = 'PP7_TT3';
        case 4            
            TTfn = 'PP3_TT4';
    end
elseif isempty(strfind(clusterList(1).name,'SS')) && isempty(strfind(clusterList(1).name,'PP')) % oregon MClust
    TTfn = ['TT' num2str(tNum)];
end

%% MOST OF THE REST IS FROM MCLUST SOURCE CODE

%% calculate features
featuresToCalc = {'feature_Energy','feature_WavePC1'};
nFeat = length(featuresToCalc);
featureFile = cell(nFeat,1);
needToCalculate = true(nFeat,1);
FDext = '.fd';
for iF = 1:nFeat
	featureFile{iF} = fullfile(folder, [TTfn '_' featuresToCalc{iF} FDext]);
	if exist(featureFile{iF}, 'file')
		needToCalculate(iF) = false;
	end
end

% Calculate features
if any(needToCalculate)
	% Load neural data (as a whole for now - only do blocks if we need it)
    TText = '.ntt';
    fn = fullfile(folder, [TTfn TText]);
    [T,WV] = LoadTT_NeuralynxNT(fn);
    WV = tsd(T, WV);
    
	nSpikes = length(WV.range());
	FeatureTimestamps = WV.range(); 
	FeatureIndex = 1:nSpikes; %#ok<NASGU>
	TT_file_name = TTfn; %#ok<NASGU>
	ChannelValidity = [1 1 1 1]';
	
	for iF = 1:nFeat
		if needToCalculate(iF)
			[FeatureData, FeatureNames, FeaturePar] = feval(featuresToCalc{iF}, WV, ChannelValidity); %#ok<NASGU>
			FD_av = mean(FeatureData);
			FD_sd = std(FeatureData)+eps;
            Normalized = false;
			save(featureFile{iF}, ...
				'FeatureIndex','FeatureTimestamps','FeatureData', 'ChannelValidity', 'FeatureNames', ...
				'Normalized', 'FeaturePar','FD_av','FD_sd', 'TT_file_name', '-mat');
			disp([  ' Wrote ' featureFile{iF} ' as a .mat formatted file']);
        else
            disp([  ' Skipping ' featureFile{iF} ', already calculated.']);
		end
	end
else
	for iF = 1:nFeat
            disp([  ' Skipping ' featureFile{iF} ', already calculated.']);
	end		
end
% Fill list of features
Features = {};
for iF = 1:nFeat
	load(featureFile{iF}, 'FeatureTimestamps', 'FeatureNames', '-mat')
	for iD = 1:length(FeatureNames)
        Features{end+1}.name = FeatureNames{iD};
        Features{end}.fdFile = featureFile{iF};
        Features{end}.fdColumn = iD;
        Features{end}.inMemory = false;
	end
end
T = FeatureTimestamps;
F = Features;

%%  initialize
nSpikes = length(T);
nFeat = length(F);
FD = nan(nSpikes, nFeat);

%% get data
for iF = 1:nFeat
    load(F{iF}.fdFile,'-mat')
    col = F{iF}.fdColumn;
    FD(:,iF) = FeatureData(:,col);
end

%% get spikes
clusterFile = fullfile(folder, [TTfn '.clusters']);
S = 1:nSpikes;
clear Clusters
load(clusterFile,'-mat')
if exist('Clusters','var')      % MClust 4.3
    Cluster = Clusters{cNum};
    nLimits = length(Cluster.featuresX);
    for iF = 1:nLimits
        load(Cluster.featuresX{iF}.fdFile,'-mat')
        xFD = FeatureData(:,Cluster.featuresX{iF}.fdColumn);
        load(Cluster.featuresY{iF}.fdFile,'-mat')
        yFD = FeatureData(:,Cluster.featuresY{iF}.fdColumn);
        OK = inpolygon(xFD(S), yFD(S), Cluster.xg{iF}, Cluster.yg{iF});
        S = S(OK);
    end
else                            % MClust 3.5
    Cluster = MClust_Clusters{cNum};
    nLimits = length(Cluster.xdimNames);
    for iF = 1:nLimits
        load(Cluster.xdimSources{iF,1},'-mat')
        xFD = FeatureData(:,Cluster.xdimSources{iF,2});
        load(Cluster.ydimSources{iF,1},'-mat')
        yFD = FeatureData(:,Cluster.ydimSources{iF,2});
        OK = inpolygon(xFD(S), yFD(S), Cluster.cx{iF}, Cluster.cy{iF});
        S = S(OK);
    end
end

%% calculate the stats
L = MClust.ClusterQuality.L_Ratio(FD, S);
L_ratio = L.Lratio;
IsoD = MClust.ClusterQuality.IsolationDistance(FD, S);
