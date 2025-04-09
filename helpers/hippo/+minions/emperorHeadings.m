
% Create labels for each column in the array produced by emperorPenguin.
%
%   USAGE
%       colHeaders = minions.emperorHeadings(include,ccComps)
%       include         structure indicating which measures to calculate
%       ccComps         matrix indicating which sessions to compare for spatial correlations
%
%   OUTPUT
%       colHeaders      cell array of string labels
%
%   SEE ALSO
%       meta.emperorPenguin minions.emperorSettings
%
% Written by BRK 2017

function colHeaders = emperorHeadings(include,ccComps)

colHeaders = {'Folder','Tetrode','Cluster','Mean rate','Peak rate','Total spikes','Quality','L_Ratio','Isolation distance'};
if include.spikeWidth
    colHeaders = [colHeaders,'Spike width (usec)'];
end
if include.sss
    colHeaders = [colHeaders,'Spatial info','Selectivity','Sparsity'];
end
if include.coherence
    colHeaders = [colHeaders,'Coherence'];
end
if include.fields
    colHeaders = [colHeaders,'Number of fields','Mean field size (cm2)','Max field size (cm2)','COM x','COM y','Border score'];
end
if include.grid
    colHeaders = [colHeaders,'Grid score','Grid spacing','Orientation 1','Orientation 2','Orientation 3'];
end
if include.HD
    colHeaders = [colHeaders,'Mean vector length','Mean angle'];
end
if include.speed
    colHeaders = [colHeaders,'Speed score'];
end
if include.theta
    colHeaders = [colHeaders,'Theta index spikes','Theta index LFP'];
end
if include.obj
    colHeaders = [colHeaders, ...
        'Rate ratio O1', ...
        'Rate ratio O2', ...
        'P val rate O1', ...
        'P val rate O2', ...
        'P val rate all objs', ...
        'Time ratio O1', ...
        'Time ratio O2', ...
        'P val time O1', ...
        'P val time O2', ...
        'P val time all objs'];
end
if include.CC
    CC_colHeaders = cell(1,size(ccComps,1));  % make column headers
    for iCorr = 1:size(ccComps,1)
        CC_colHeaders{iCorr} = ['CC ',num2str(ccComps(iCorr,1)),' vs ',num2str(ccComps(iCorr,2))];
    end
    colHeaders = [colHeaders,CC_colHeaders];   % add CC column headers
end