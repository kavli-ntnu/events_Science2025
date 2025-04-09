
function [dists_pool_match, dists_pool_mismatch] = stability_seq(trialType)

ds = dir('N:\benjamka\events\data\sequence\trialStability');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_match = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({sprintf('%s_match', trialType)}, 1, length(names)), 'uniformoutput', false)));
inds_mismatch = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({sprintf('%s_mismatch', trialType)}, 1, length(names)), 'uniformoutput', false)));
inds_MEC = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'_MEC'}, 1, length(names)), 'uniformoutput', false)));
inds_CA1 = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'_CA1'}, 1, length(names)), 'uniformoutput', false)));
match_names = names(inds_match & ~inds_MEC & ~inds_CA1);
mismatch_names = names(inds_mismatch & ~inds_MEC & ~inds_CA1);

dists_pool_match = [];
dists_pool_mismatch = [];
for i = 1:length(match_names)
    load(fullfile(ds(1).folder, match_names{i}))
    dists_pool_match = [dists_pool_match, nanmean(dists_all(:))];
    load(fullfile(ds(1).folder, mismatch_names{i}))
    dists_pool_mismatch = [dists_pool_mismatch, nanmean(dists_all(:))];
end

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