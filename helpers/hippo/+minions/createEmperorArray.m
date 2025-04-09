
% Add each measure calculated in emperorPenguin into a single cell array.
%
%   USAGE
%       emperor = minions.createEmperorArray(clusterData,numExp,include)
%       clusterData     structure for storing all data
%       numExp          double indicating total number of experiments
%
%   OUTPUT
%       emperor         cell array with all data
%
%   SEE ALSO
%       meta.emperorPenguin
%
% Written by BRK 2017

function emperor = createEmperorArray(clusterData,numExp)

%% extract names of measures
fields = fieldnames(clusterData);
fields = fields(cellfun(@isempty,strfind(fields,'Map')));
numFields = length(fields);

%% add each measure in a new column
emperor = [];
for iExp = 1:numExp
    for iField = 1:numFields
        if iField == 1
            expData(:,1) = eval(sprintf('{clusterData(:,:,iExp).%s}',fields{iField}));
        else
            expData(:,size(expData,2)+1) = eval(sprintf('{clusterData(:,:,iExp).%s}',fields{iField}));
        end
    end
    
    % delete extra rows
    expData(cellfun(@isempty,expData(:,1)),:) = [];
    % sort data by tetrode and cluster
    expData = sortrows(expData,[find(strcmpi(fields,'tetrode')) find(strcmpi(fields,'cluster'))]);
    % append to full data set
    emperor = [emperor; expData];
    clear expData
end
    