
% Compute bootstrapped effect size.
%
%   USAGE
%       [m,l,u,sampleData] = calc.bootEffectSize(x,y,type,<p>,<nStrap>)
%       x              vector of data for group 1
%       y              vector of data for group 2
%       type           'mean' or 'median'
%       p              (optional) percentile (default = 95)
%       nStrap         (optional) number of iterations (default = 10000)
%
%   OUTPUTS
%       m              grand mean/median
%       l              lower bound
%       u              upper bound
%       sampleData     1 x nStrap array of sample means/medians
%
%   SEE ALSO
%       calc.bootCI
%       plt.swarmCI
%
% Written by BRK 2019

function [m,l,u,sampleData] = bootEffectSize(x,y,type,p,nStrap)

%% defaults
if nargin < 4
    p = 95;
end
if nargin < 5
    nStrap = 10000;
end

%% sample data with replacement 10000 times, computing the average difference of each sample
d = nan(nStrap,1);
t2all = [];
for i = 1:nStrap
    t1 = randsample(x,numel(x),'true');
    t2 = randsample(y,numel(y),'true');
    t2all = [t2all; t2];
    if strcmpi(type,'mean')
        d(i) = nanmean(t2) - nanmean(t1);
    elseif strcmpi(type,'median')
        d(i) = nanmedian(t2) - nanmedian(t1);
    end
end

%% grand average
if strcmpi(type,'mean')
    m = nanmean(d);
elseif strcmpi(type,'median')
    m = nanmedian(d);
end

%% confidence interval
lims = [(100-p)/2 100-((100-p)/2)];
cInt = prctile(sort(d),lims);
l = cInt(1);
u = cInt(2);

cohens_d = abs(m / std(t2all(:)))