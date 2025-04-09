
% Write input file for BNT by extracting names of cluster timestamp files
% in specified directories.
%
%   USAGE
%       writeInputBNT(inputFile, folder, arena, clusterFormat, <sessionName>, <cutFolder>)
%       inputFile           string specifying where to write the input file
%       folder              directory with clusters, position data, etc.
%       arena               string with shape and size of recording arena (e.g. 'cylinder 60 60' or 'box 100 100')
%       clusterFormat       string describing spike timestamp files (e.g. 'MClust' or 'Tint')
%       sessionName         optional. String with session name if multiple sessions are stored in one folder
%                           (N.B.: if you have .pos files, session name is the whole name of the .pos file without the .pos itself,
%                           e.g. session name for Mouse58313_20170322_02_5Hz20mW.pos is 'Mouse58313_20170322_02_5Hz20mW')
%       cutFolder           optional. Directory where cut files should be searched for. If omitted,
%                           then `folder` is used.
%
%   SEE ALSO
%       penguin emperorPenguin emperorPenguinSelect startup
%
% Written by BRK 2015

function writeInputBNT(inputFile, folder, arena, clusterFormat, sessionName, cutFolder)

%% check inputs
if iscell(folder)
    folder = folder{1};
end
if exist('sessionName','var')
    if iscell(sessionName)
        if isempty(sessionName)
            sessionName = '';
        else
            sessionName = sessionName{1};
        end
    end
else
    sessionName = '';
end
if nargin < 6 || isempty(cutFolder)
    cutFolder = folder;
end

%% get file list
if strcmpi(clusterFormat,'MClust') || strcmpi(clusterFormat,'SS_t')

    cutList = dir(fullfile(cutFolder, '*.t*'));

elseif strcmpi(clusterFormat,'Tint')
    
    % find all .cut files in folder
    cutFiles = extractfield(dir(fullfile(cutFolder,'*.cut')),'name'); 
    
    % find .cut files for a particular session
    if numel(sessionName)
        inds = ~cellfun(@isempty,cellfun(@strfind,cutFiles,repmat({sessionName},1,length(cutFiles)),'uniformoutput',0));
        cutList = cutFiles(inds);
    else 
        cutList = cutFiles;
    end
    
else

    error('Cluster format not recognized.')

end

%% find all tetrode and cluster numbers
if ~isempty(cutList)
    cellMatrix = nan(500,2);
    flagPP = false;
    if strcmpi(clusterFormat,'MClust')

        wrongFiles = false(1, length(cutList));
        for iCluster = 1:length(cutList)
            splits = regexp(cutList(iCluster).name,'_','split');
            if length(splits) == 1
                wrongFiles(iCluster) = true;
                continue;
            end
            try
                [~, cutFilename, ~] = helpers.fileparts(cutList(iCluster).name);
                if length(cutList(iCluster).name) <= 9      % oregon
                    t_num = cellfun(@str2double,strtok(splits(1),'T'));
                    c_num = cellfun(@str2double,strtok(splits(2),'.'));
                elseif length(cutList(iCluster).name) >= 9 && isempty(strfind(cutList(iCluster).name,'SS'))  % norway
                    flagPP = true;
                    tIdx = strfind(cutFilename, 'T');
                    if isempty(tIdx)
                        continue;
                    end
                    tIdx = tIdx(end);
                    candidates = regexp(cutFilename(tIdx+1:end), '\d*', 'match');
                    if length(candidates) < 2
                        continue;
                    end
                    t_num = str2double(candidates{1});
                    c_num = str2double(candidates{2});
                else
                    continue
                end
                cellMatrix(iCluster,1) = t_num;
                cellMatrix(iCluster,2) = c_num;
            catch
                continue;
            end
        end
        cutList(wrongFiles) = [];

    elseif strcmpi(clusterFormat,'SS_t')
        
        wrongFiles = false(1, length(cutList));
        for iCluster = 1:length(cutList)
            splits = regexp(cutList(iCluster).name,'_','split');
            if length(splits) == 1
                wrongFiles(iCluster) = true;
                continue;
            end
            c_num = cellfun(@str2double,strtok(splits(end),'.'));
            if length(cutList(iCluster).name) <= 13 && ~isempty(strfind(cutList(iCluster).name,'SS'))    % oregon
                t_num = cellfun(@str2double,strtok(splits(1),'T'));
            elseif length(cutList(iCluster).name) >= 13   % norway
                flagPP = true;
                t_num = cellfun(@str2double,strtok(splits(2),'T'));
            else
                continue
            end
            cellMatrix(iCluster,1) = t_num;
            cellMatrix(iCluster,2) = c_num;
        end
        cutList(wrongFiles) = [];
        
    elseif strcmpi(clusterFormat,'Tint')
        rowCount = 1;
        for iTetrode = 1:length(cutList)
            
            % to find the tetrode number, look for a digit that is not preceded or followed by a digit
            indPos = regexp(cutList{iTetrode},'(?<!\d)(\d)(?!\d)');
            t_num = str2double(cutList{iTetrode}(indPos(end)));
            
            % session name could be ambiguous, so make sure it is followed by tetrode number
            if isempty(strfind(cutList{iTetrode},[sessionName,'_',num2str(t_num) '_'])) ...
                    && isempty(strfind(cutList{iTetrode},[sessionName,'_',num2str(t_num) '.']))
                
                % if not, remove that cut and continue
                cutList{iTetrode} = '';
                continue
            end
            
            clusters = unique(io.axona.getCut(fullfile(cutFolder,cutList{iTetrode})));
            clusters = clusters(clusters ~=0);
            for iCluster = 1:length(clusters)
                c_num = clusters(iCluster);
                cellMatrix(rowCount,1) = t_num;
                cellMatrix(rowCount,2) = c_num;
                rowCount = rowCount + 1;
            end
        end
        
        % update list in case some were removed above
        cutList = cutList(~cellfun(@isempty,cutList));
    end
    
    cellMatrix(all(arrayfun(@isnan,cellMatrix),2),:) = [];

    %% create unit list for input file
    tetrodes = unique(cellMatrix(:,1));
    unitList = [];
    for iTetrode = 1:length(tetrodes)
        clusters = cellMatrix(cellMatrix(:,1) == tetrodes(iTetrode),2);
        unitList = [unitList, num2str(tetrodes(iTetrode)), '  ', num2str(clusters'), '; '];
    end

end

%% create cut list for input file
cutsForBNT = [];
if isempty(cutList)

    error('Did not find any clusters.')

else

    if ~strcmpi(cutFolder, folder)
        cutAddon = cutFolder;
    else
        cutAddon = [];
    end
    
    if flagPP
        % get cut file names
        cutNames = extractfield(cutList,'name');
        % find digits that follow PP in each name
        PPinds = cellfun(@regexp,cutNames,repmat({'(?<=PP)\d'},1,length(cutNames)),'uniformoutput',0);
        % get unique list of them
        PPnums = unique(cellfun(@(x,y) str2double(x(y)),cutNames,PPinds),'stable');
        % repeat for tetrode nums to have PP nums in the correct order
        TTinds = cellfun(@regexp,cutNames,repmat({'(?<=TT)\d'},1,length(cutNames)),'uniformoutput',0);
        TTnums = unique(cellfun(@(x,y) str2double(x(y)),cutNames,TTinds),'stable');
        [~,sortInds] = sort(TTnums);
        PPnums = PPnums(sortInds);
    end
    
    if strcmpi(clusterFormat,'Tint')   % Tint

        for iTetrode = 1:length(cutList)
            cutsForBNT = [cutsForBNT, fullfile(cutFolder,cutList{iTetrode}), '; '];
        end

    elseif flagPP && strcmpi(clusterFormat,'MClust')   % norway MClust
        
        for iPP = 1:numel(PPnums)
            cutsForBNT = [cutsForBNT,fullfile(cutAddon, ['PP' num2str(PPnums(iPP)) '_TT%u_%u; '])];
        end

    elseif flagPP && strcmpi(clusterFormat,'SS_t')   % norway SS

        for iPP = 1:numel(PPnums)
            cutsForBNT = [cutsForBNT,fullfile(cutAddon, ['PP' num2str(PPnums(iPP)) '_TT%u_SS_%02u; '])];
        end
        
    elseif ~flagPP && strcmpi(clusterFormat,'MClust')   % oregon MClust

        for i = 1:length(tetrodes)
            cutsForBNT = [cutsForBNT,fullfile(cutAddon, 'TT%u_%u; ')];
        end

    elseif ~flagPP && strcmpi(clusterFormat,'SS_t')   % oregon SS

        cutsForBNT = fullfile(cutAddon, 'TT%u_SS_%02u; ');

    end
end

%% write BNT input file
fileID = data.safefopen(inputFile,'w');
if strcmpi(clusterFormat,'Tint')
    if ~numel(sessionName)
        sessionName = extractfield(dir(fullfile(folder,'*.pos')),'name');
        sessionName = sessionName{1}(1:end-4);
    end
    sessionPath = fullfile(folder,sessionName);
    fprintf(fileID,'Name: general; Version: 1.0\nSessions %s\nCuts %s\nUnits %s\nShape %s',sessionPath,cutsForBNT,unitList,arena);
else
    fprintf(fileID,'Name: general; Version: 1.0\nSessions %s\nCuts %s\nUnits %s\nShape %s',folder,cutsForBNT,unitList,arena);
end

%% issue warning if duplicate cache files are detected and some have manual changes
global hippoGlobe
if exist('hippoGlobe','var') && isfield(hippoGlobe,'checkCache') && ~hippoGlobe.checkCache
    return  % user has suppressed warning
else
    myDir = dir(folder);
    names = extractfield(myDir,'name');
    indPosClean = find(~cellfun(@isempty,strfind(names,'posClean.mat')));
    posUpdates = 0;
    if length(indPosClean) > 1
        for i = 1:length(indPosClean)
            info = load(fullfile(folder,names{indPosClean(i)}),'info');
            if isfield(info,'manual') && info.manual
                posUpdates = posUpdates + 1;
            end
        end
    end
    if posUpdates > 0
        waitfor(warndlg(['Multiple posClean.mat files detected, probably from changing folder names.' ...
                    'Since some have been manually corrected, you should consider' ...
                    'deleting unwanted cache files and restarting the analysis!']));
    end
end
