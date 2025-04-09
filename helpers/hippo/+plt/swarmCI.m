
% Make swarm plots with bootstrapped confidence intervals alongside each swarm.
%
%   USAGE
%       plt.swarmCI(data,type,<p>,<nStrap>)
%       data           cell array of data, each cell is a group
%       type           'mean' or 'median'
%       p              (optional) percentile (default = 95)
%       nStrap         (optional) number of iterations (default = 10000)
%
%   SEE ALSO
%       calc.bootCI
%       calc.bootEffectSize
%       plotSpread
%
% Written by BRK 2019

function swarmCI(x,type,p,nStrap)

%% defaults
if nargin < 3
    p = 95;
end
if nargin < 4
    nStrap = 10000;
end

%% plot swarms
markerSize = 20;
lineWidth = 3;
nGroups = length(x);
xVals = 1:2:((nGroups*2)-1);
figure, hold on
plotSpread(x,'xvalues',xVals,'spreadWidth',1.5)

%% add bootstrapped confidence intervals
for i = 1:nGroups
    [m,l,u] = calc.bootCI(x{i},type,p,nStrap);
    e = errorbar(xVals(i) + 0.75,m,l-m,u-m,'-','linew',lineWidth,'color',[.7 .7 .7]);
    e.CapSize = 0;
    plot(xVals(i) + 0.75,m,'b.','markers',markerSize)
end
xlim([0 nGroups*2])