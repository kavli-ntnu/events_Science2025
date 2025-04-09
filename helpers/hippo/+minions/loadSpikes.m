
% Extract spike times from previously saved file created by BNT to avoid recalculating.
%
%   USAGE
%       spikes = minions.loadSpikes(raw,labels,clusterNum,session,<exptHalf>)
%       raw            cell array of data
%       labels         cell array of strings containing column headers
%       clusterNum     string specifying cluster number
%       session        string specifying session name
%       exptHalf       Optional. string or double specifying experiment half
%
%   OUTPUTS
%       spikes         vector of spike times
%   SEE ALSO
%       data.getSpikeTimes minions.loadPosClean
%
% Written by BRK 2017

function spikes = loadSpikes(raw,labels,clusterNum,session,exptHalf)

%% check inputs
global hippoGlobe
if (iscell(raw) + iscell(labels) + helpers.isstring(clusterNum) + helpers.isstring(session)) < 4
    error('Incorrect input format (type ''help <a href="matlab:help findSpikeFile">findSpikeFile</a>'' for details).');
end
if exist('exptHalf','var')
    % convert to strings
    if isnumeric(exptHalf)
        exptHalf = num2str(exptHalf);
    end
    if isnumeric(raw{1,strcmpi(labels,'exptHalf')})
        for iRow = 1:size(raw,1)
            raw{iRow,strcmpi('exptHalf',labels)} = num2str(raw{iRow,strcmpi('exptHalf',labels)});
        end
    end
    raw = extract.rows(raw,labels,'keep','exptHalf',exptHalf);
end

%% search in correct directory
folder = extract.cols(raw,labels,'folder','cell num',clusterNum,'session',session);
splits = regexp(folder,'\','split');
tetrode = extract.cols(raw,labels,'tetrode','cell num',clusterNum,'session',session);
cluster = extract.cols(raw,labels,'cluster','cell num',clusterNum,'session',session);
searchStr = [splits{1}{end} '_T' num2str(tetrode) 'C' num2str(cluster) '_'];
d = dir(folder{1});
names = extractfield(d,'name');
dates = extractfield(d,'datenum');
numFiles = sum(~cellfun(@isempty,cellfun(@strfind,names',cellstr(repmat(searchStr,length(d),1)),'uniformoutput',0)));
if numFiles
    
    spkInd = find(~cellfun(@isempty,cellfun(@strfind,names',cellstr(repmat(searchStr,length(d),1)),'uniformoutput',0)));
    spikeFile = names(spkInd);
    
    %% if there are multiple versions, use most recent one
    if numFiles > 1
        [~,sortInds] = sort(dates(~cellfun(@isempty,cellfun(@strfind,names',cellstr(repmat(searchStr,length(d),1)),'uniformoutput',0))),'descend');
        spikeFile = spikeFile(sortInds == 1);
        spkInd = find(~cellfun(@isempty,cellfun(@strfind,names',cellstr(repmat(spikeFile,length(d),1)),'uniformoutput',0)));
    end
    
    %% check that cached file was made after all changes to .t files
    d_tFiles = dir(fullfile(folder{1,1},'*.t'));
    dates_tFiles = extractfield(d_tFiles,'datenum');
    if all(dates(spkInd) > dates_tFiles) % okay to load
        spikeFile = fullfile(folder{1,1},spikeFile{1,1});
        load(spikeFile)
        spikes = cellTS;
    else % need to use BNT
        warning(sprintf('Cached file is not recent enough for T%dC%d in %s.\n Attempting to load with BNT...\n',tetrode,cluster,folder{1}))
        writeInputBNT(hippoGlobe.inputFile,folder{1},hippoGlobe.arena,hippoGlobe.clusterFormat);
        data.loadSessions(hippoGlobe.inputFile);
        spikes = data.getSpikeTimes([tetrode cluster]);
    end
    
else % cached file not found, use BNT
    warning(sprintf('Did not find spike file for T%dC%d in %s.\n Attempting to load with BNT...\n',tetrode,cluster,folder{1}))
    writeInputBNT(hippoGlobe.inputFile,folder{1},hippoGlobe.arena,hippoGlobe.clusterFormat);
    data.loadSessions(hippoGlobe.inputFile);
    spikes = data.getSpikeTimes([tetrode cluster]);
end