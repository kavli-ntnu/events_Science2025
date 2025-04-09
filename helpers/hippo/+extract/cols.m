
% Select column(s) from array with optional filtering of the data first.
%
%   USAGE
%       colsOut = extract.cols(array,labels,colsToGet,varagin)
%       array          cell array of data
%       labels         cell array of strings containing column headers
%       colsToGet      columns to extract specified by string, cell array of strings, or ':' for all
%       varargin       string or double comparisons for extracting data
%                       (e.g. 'session',sessions{1},'mean rate','>=',10
%                       will filter for the first session where mean rate >= 10)
%
%   OUTPUT
%       colsOut         column(s) extracted from array
%
%   SEE ALSO
%       extract.rows
%
% Written by BRK 2016

function colsOut = cols(array,labels,colsToGet,varargin)

%% check inputs
if (iscell(array) + iscell(labels) + (iscell(colsToGet) || helpers.isstring(colsToGet))) < 3
    error('Incorrect input format (type ''help <a href="matlab:help extract.cols">extract.cols</a>'' for details).');
end

%% inspect columns
if ~strcmpi(colsToGet,':')
    columns = ismember(lower(labels),lower(colsToGet));
else
    columns = ':';
end

if ~isempty(varargin)
    %% double comparisons
    dStartInds = find(cellfun(@isnumeric,varargin)) - 2;
    dComps = {};
    indsToRemove = [];
    for iComp = 1:length(dStartInds)
        temp = varargin(dStartInds(iComp):dStartInds(iComp) + 2);
        if iComp == 1
            dComps = temp;
            indsToRemove = dStartInds(iComp):dStartInds(iComp) + 2;
        else
            dComps = [dComps; temp];
            indsToRemove = [indsToRemove, dStartInds(iComp):dStartInds(iComp) + 2];
        end
    end
    modVarargin = varargin;
    modVarargin(indsToRemove) = '';
    
    %% string comparisons
    sComps = {};
    for iComp = 1:2:length(modVarargin)
        temp = modVarargin(iComp:iComp + 1);
        if iComp == 1
            sComps = temp;
        else
            sComps = [sComps; temp];
        end
    end
    
    %% get logical arrays for each comparison
    logCount = 1;
    for iComp = 1:size(sComps,1)
        myLog{logCount} = eval(sprintf('strcmpi(array(:,strcmpi(''%s'',labels)),''%s'');',sComps{iComp,1},sComps{iComp,2}));
        logCount = logCount + 1;
    end
    for iComp = 1:size(dComps,1)
        myLog{logCount} = eval(sprintf('cell2mat(array(:,strcmpi(''%s'',labels))) %s %d;',dComps{iComp,1},dComps{iComp,2},dComps{iComp,3}));
        logCount = logCount + 1;
    end
    
    %% condense to one logical
    nLog = length(myLog);
    if nLog == 1
        totalLog = myLog{nLog};
    else
        logCount = nLog;
        while nLog > 1
            if nLog == logCount     % first time
                totalLog = myLog{nLog} & myLog{nLog-1};
            else
                totalLog = totalLog & myLog{nLog-1};
            end
            nLog = nLog - 1;
        end
    end
    colsOut = array(totalLog,columns);
    
else
    colsOut = array(:,columns);
end

if length(colsOut) == 1
    colsOut = colsOut{1};
end
if ~iscell(colsOut)
    if ischar(colsOut)
        colsOut = {colsOut};
    end
end
