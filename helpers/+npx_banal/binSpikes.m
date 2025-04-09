
function [smat, smat_n, smat_z, fr] = binSpikes(sCell, posT, dt)

if max(diff(posT)) > 5
    warning('Position samples are discontinuous with gap > 5 secs between samples!')
end
N = numel(sCell);
timeInt = posT(1):dt:posT(end);
smat = nan(N,numel(timeInt)-1);
smat_n = smat;
smat_z = smat;
for i = 1:N
    s_counts = histcounts(sCell{i},timeInt);
    smat(i,:) = s_counts;
    smat_n(i,:) = s_counts / ((nanmax(s_counts) - nanmin(s_counts)) + 5); % soft norm
end
smat = smat(any(~isnan(smat),2),:);
smat_n = smat_n(any(~isnan(smat_n),2),:);
smat_z = zscore(smat,[],2); % normalize 1st dim
fr = sum(smat_n,1)/size(smat_n,1); % divide by number of nrns to keep units sensible