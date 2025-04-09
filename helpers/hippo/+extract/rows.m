
% Select rows from array to keep or remove based on the data they contain.
%
%   USAGE
%       array = extract.rows(array,labels,type,varagin)
%       array          cell array of data
%       labels         cell array of strings containing column headers
%       type           'keep' or 'remove'
%       varargin       string or double comparisons for selecting data
%                       (e.g. 'session',sessions{1},'mean rate','>=',10
%                       will select the first session where mean rate >= 10)
%
%   OUTPUT
%       array          filtered array
%
%   NOTES
%       varargin strings are case insensitive for columns headers, but are case
%       sensitive for strings appearing in array
%
%       varargin string values can be cell arrays of string
%       (e.g. 'session',{'BL','CNO'})
%
%   SEE ALSO
%       extract.cols
%
% Written by BRK 2016

function array = rows(array,labels,type,varargin)

%% check inputs
if (iscell(array) + iscell(labels) + helpers.isstring(type,'keep','remove')) < 3
    error('Incorrect input format (type ''help <a href="matlab:help extract.rows">extract.rows</a>'' for details).');
end

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

%% remove missing values
for iComp = 1:size(sComps,1)
    if sum(cellfun(@isempty,array(:,ismember(lower(labels),lower(sComps{iComp,1})))))
        emptyInds = cellfun(@isempty,array(:,ismember(lower(labels),lower(sComps{iComp,1}))));
        array = array(~emptyInds,:);
    end
end
    
%% select rows
if strcmpi(type,'keep')
    for iComp = 1:size(dComps,1)
        eval(sprintf('array = array(cell2mat(array(:,ismember(lower(labels),''%s''))) %s %d,:);',lower(dComps{iComp,1}),dComps{iComp,2},dComps{iComp,3}));
    end
    for iComp = 1:size(sComps,1)
        inds = ismember(array(:,ismember(lower(labels),lower(sComps{iComp,1}))),sComps{iComp,2});
        array = array(inds,:);
    end
elseif strcmpi(type,'remove')
    for iComp = 1:size(dComps,1)
        eval(sprintf('array(cell2mat(array(:,ismember(lower(labels),''%s''))) %s %d,:) = [];',lower(dComps{iComp,1}),dComps{iComp,2},dComps{iComp,3}));
    end
    for iComp = 1:size(sComps,1)
        inds = ismember(array(:,ismember(lower(labels),lower(sComps{iComp,1}))),sComps{iComp,2});
        array = array(~inds,:);
    end
end