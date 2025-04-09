
% Extract positions from previously saved file created by BNT to avoid recalculating.
% Uses mapLimits and posSpeedFilter from hippoGlobe.
%
%   USAGE
%       posAve = minions.loadPosClean(folder,<scale>)
%       folder         string specifying folder to search in
%       scale          (optional) 1 scales data to arena info from
%                      hippoGlobe (default), 0 does not scale data
%
%   OUTPUTS
%       posAve         N x 3 array of position data
%   SEE ALSO
%       data.getPositions minions.loadSpikes
%
% Written by BRK 2017

function posAve = loadPosClean(folder,scale)

%% check inputs
global hippoGlobe

if ~exist('scale','var')
    scale = 1;
elseif ~isnumeric(scale) || (scale ~= 0 && scale ~= 1)
    warning('Scale input not recognized, will attempt to scale to arena.')
end
if ~isfield(hippoGlobe,'posSpeedFilter')
    hippoGlobe.posSpeedFilter = [0 0]; % default, no filter
end

%% load position data
splits = regexp(folder,'\','split'); 
fullname = fullfile(folder,[splits{end},'_posClean.mat']);
try
    L = load(fullname,'positions');
    posAve = L.positions;
    
    %% scale to map limits if requested
    if scale
        posAve(:,2) = minions.rescaleData(posAve(:,2),hippoGlobe.mapLimits(1),hippoGlobe.mapLimits(2));
        posAve(:,3) = minions.rescaleData(posAve(:,3),hippoGlobe.mapLimits(3),hippoGlobe.mapLimits(4));
    end
    
    %% speed threshold
    if (hippoGlobe.posSpeedFilter(1) ~= 0) || (hippoGlobe.posSpeedFilter(2))
        toRemove = general.speedThreshold(posAve,hippoGlobe.posSpeedFilter(1),hippoGlobe.posSpeedFilter(2));
        selected = false(1,size(posAve,1));
        selected(toRemove) = true;
        posAve(selected,2:end) = nan;
    end
    
catch % posClean.mat wasn't found, load the slower way with BNT
    warning(sprintf('Did not find file %s.\n Attempting to load with BNT...\n',fullname))
    writeInputBNT(hippoGlobe.inputFile,folder,hippoGlobe.arena,hippoGlobe.clusterFormat);
    data.loadSessions(hippoGlobe.inputFile);
    posAve = data.getPositions('speedFilter',hippoGlobe.posSpeedFilter);
end


