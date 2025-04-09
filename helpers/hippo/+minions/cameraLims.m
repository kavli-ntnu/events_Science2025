% Correct tracking errors by removing samples outside of limits defined in
% hippoGlobe.cameraLimits. Will abort if there are multiple posClean.mat
% files in the folder or if the posClean.mat file has manual corrections
% already (probably from minions.trackerChecker).
%
%   USAGE
%       minions.cameraLims
%
%   SEE ALSO
%       data.getPositions minions.trackerChecker
%
% Written by BRK 2018

function cameraLims(folder)

global hippoGlobe gBntData gCurrentTrial

%% choose recording session if not specified
if nargin < 1
    folder = uigetdir('','Select recording session');
end

%% detect posClean.mat files
myDir = dir(folder);
names = extractfield(myDir,'name');
ind = find(~cellfun(@isempty,strfind(names,'posClean.mat')));

%% only continue for single posClean.mat file without prior manual corrections
if numel(ind) > 1
    fprintf('Multiple posClean files already. Will not use camera lims! \n\n\n')
    return
elseif numel(ind) == 1
    splits = regexp(folder,'\','split');
    posUpdates = 0;
    load(fullfile(folder,names{ind}),'info');
    if isfield(info,'manual') && info.manual
        posUpdates = posUpdates + 1;
    end
    if posUpdates > 0
        fprintf('Will not override manual position corrections. \n\n\n')
        return
    else
        helpers.deleteCache(hippoGlobe.inputFile);
        fprintf('Cache has been deleted! %s \n\n\n',folder)
    end
end

%% load session to create posClean.mat file
writeInputBNT(hippoGlobe.inputFile,folder,hippoGlobe.arena,hippoGlobe.clusterFormat)
data.loadSessions(hippoGlobe.inputFile);
pos = data.getPositions('speedFilter',hippoGlobe.posSpeedFilter); % this is just to create posClean.mat

try
    %% identify posClean.mat file
    myDir = dir(folder);
    names = extractfield(myDir,'name');
    ind = find(~cellfun(@isempty,strfind(names,'posClean.mat')));
    
    %% load it and get some information
    L = load(fullfile(folder,names{ind}));
    positions = L.positions;
    info = L.info;
    if isfield(L,'creationTime')
        creationTime = L.creationTime;
    end
    
    %% exclude bad samples
    toKeep = inpolygon(positions(:,2),positions(:,3),hippoGlobe.cameraLimits(:,1),hippoGlobe.cameraLimits(:,2));
    positions(~toKeep,2:end) = nan;
    dateTime = datestr(clock,30);
    info.manual = true;
    info.manualTimestamp = dateTime;
    info.manualNanInds = ~toKeep;
    
    %% overwrite posClean.mat file and current BNT data
    if exist('creationTime','var')
        save(fullfile(folder,names{ind}),'positions','info','creationTime');
    else
        save(fullfile(folder,names{ind}),'positions','info');
    end
    gBntData{gCurrentTrial}.posClean = positions;
    
catch
    %% remove cached files if something goes wrong
    helpers.deleteCache(hippoGlobe.inputFile);
    fprintf('Cache has been deleted due to error! %s\n',folder)
end
