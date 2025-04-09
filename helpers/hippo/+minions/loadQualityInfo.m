
% Load previously saved information about cluster quality.
%
%   USAGE
%       [quality,L_ratio,isoDist] = minions.loadQualityInfo(folder,tetrode,cluster)
%       folder          string indicating folder name
%       tetrode         double indicating tetrode number
%       cluster         double indicating cluster number
%
%   OUTPUT
%       quality         structure for storing all data
%       L_ratio         double indicating total number of experiments
%       isoDist         structure indicating which measures to calculate
%
%   SEE ALSO
%       meta.emperorPenguin
%
% Written by BRK 2017

function [quality,L_ratio,isolationDistance] = loadQualityInfo(folder,tetrode,cluster)

%% set PP nums for Norwegian scheme
if tetrode == 1
    PP = 4;
elseif tetrode == 2
    PP = 6;
elseif tetrode == 3
    PP = 7;
elseif tetrode == 4
    PP = 3;
end

%% qualitative cluster quality
try
    load(fullfile(folder,sprintf('TT%d_%d-Quality.mat',tetrode,cluster))) % oregon
catch
    try
        load(fullfile(folder,sprintf('PP%d_TT%d_%d-Quality.mat',PP,tetrode,cluster)))  % norway
    catch
        quality = nan;
    end
end

%% quantitative cluster quality
try    % MClust 4.3
    if cluster < 10
        try
            load(fullfile(folder,sprintf('TT%d_0%d-CluQual.mat',tetrode,cluster)))  % oregon
        catch
            try
                load(fullfile(folder,sprintf('PP%d_TT%d_0%d-CluQual.mat',PP,tetrode,cluster)))  % norway
            catch
                L_ratio = nan;
                isolationDistance = nan;
            end
        end
    else
        try
            load(fullfile(folder,sprintf('TT%d_%d-CluQual.mat',tetrode,cluster)))  % oregon
        catch
            try
                load(fullfile(folder,sprintf('PP%d_TT%d_%d-CluQual.mat',PP,tetrode,cluster)))  % norway
            catch
                L_ratio = nan;
                isolationDistance = nan;
            end
        end
    end
    L_ratio = CluSep.L_Ratio.Lratio;
    isolationDistance = CluSep.IsolationDistance;
catch    % MClust 3.5
    try
        load(fullfile(folder,sprintf('TT%d_%d-CluQual_MC35.mat',tetrode,cluster)))
    catch
        L_ratio = nan;
        isolationDistance = nan;
    end
end