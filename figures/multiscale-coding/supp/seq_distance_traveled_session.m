

function [dists_pool, dists_pool_neigh] = seq_distance_traveled_session

ds = dir('N:\benjamka\events\data\sequence\dists');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_endpt = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'session_endpt'}, 1, length(names)), 'uniformoutput', false)));
inds_neigh = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'session_neigh'}, 1, length(names)), 'uniformoutput', false)));
endpt_names = names(inds_endpt);
neigh_names = names(inds_neigh);

dists_pool = [];
for i = 1:length(endpt_names)
    load(fullfile(ds(1).folder, endpt_names{i}))
    dists_pool = [dists_pool, nanmean(dists_full)];
end

dists_pool_neigh = [];
for i = 1:length(neigh_names)
    load(fullfile(ds(1).folder, neigh_names{i}))
    dists_pool_neigh = [dists_pool_neigh, nanmean(dists_full)];
end

figure, hold on

COLOR = 'k';
plot(1:2, [dists_pool; dists_pool_neigh], '-', 'color', COLOR, 'linew', 1)
plot(1:2, [nanmean(dists_pool), nanmean(dists_pool_neigh)] , 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
err1 = nanstd(dists_pool) / sqrt(sum(~isnan(dists_pool)));
err2 = nanstd(dists_pool_neigh) / sqrt(sum(~isnan(dists_pool_neigh)));
errorbar(1:2, [nanmean(dists_pool), nanmean(dists_pool_neigh)],[err1, err2] , 'color', COLOR, 'linew', 2)

load figp
fixPlot(1:2, {'Endpoint', 'Neighbor'}, '', 'Distance traveled')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 30)