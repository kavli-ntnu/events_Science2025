
% Cross correlation between two lists of spike times.
%
%   USAGE
%       calc.crossCorr(T1,T2)
%       T1      vector of spike times from cluster 1
%       T2      vector of spike times from cluster 2
%
%   SEE ALSO
%       calc.ISI MClustStats.CrossCorr
%
% Written by BRK 2017

function crossCorr(T1,T2)

binSize = 0.001; % in seconds
width = 0.5;     % in seconds

xrange = -width:binSize:width;
nBins = length(xrange);

[ACD,xrange] = MClustStats.CrossCorr(T1,T2,binSize,nBins);

bar(xrange,ACD,'FaceColor','b','EdgeColor','b');
set(gca,'XLim',[-width width]);
line([0 0],get(gca,'YLim'),'color','r');
