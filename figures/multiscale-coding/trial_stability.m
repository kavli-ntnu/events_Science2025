
function [dists_pool_match, dists_pool_mismatch] = trial_stability

ds = dir('N:\benjamka\events\data\figure-eight\trialStability');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_match = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'_match'}, 1, length(names)), 'uniformoutput', false)));
inds_mismatch = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'_mismatch'}, 1, length(names)), 'uniformoutput', false)));
match_names = names(inds_match);
mismatch_names = names(inds_mismatch);

dists_pool_match = [];
for i = 1:length(match_names)
    load(fullfile(ds(1).folder, match_names{i}))
    if isempty(strfind(match_names{i}, '_sh'))
        dists_pool_match = [dists_pool_match, nanmean(dists_all(:))];
    end
end

dists_pool_mismatch = [];
for i = 1:length(mismatch_names)
    load(fullfile(ds(1).folder, mismatch_names{i}))
    if isempty(strfind(mismatch_names{i}, '_sh'))
        dists_pool_mismatch = [dists_pool_mismatch, nanmean(dists_all(:))];
    end
end

stability_LEC = dists_pool_mismatch - dists_pool_match;

figure, hold on

COLOR = 'k';
plot(1:2, [dists_pool_match; dists_pool_mismatch], '-', 'color', COLOR, 'linew', 1)
plot(1:2, [nanmean(dists_pool_match), nanmean(dists_pool_mismatch)] , 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
err1 = nanstd(dists_pool_match) / sqrt(sum(~isnan(dists_pool_match)));
err2 = nanstd(dists_pool_mismatch) / sqrt(sum(~isnan(dists_pool_mismatch)));
errorbar(1:2, [nanmean(dists_pool_match), nanmean(dists_pool_mismatch)],[err1, err2] , 'color', COLOR, 'linew', 2)

load figp
fixPlot(1:2, {'Match', 'Mismatch'}, '', 'Distance traveled')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 30)
