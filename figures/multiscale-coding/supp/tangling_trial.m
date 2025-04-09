

function [Q_pool, Q_pool_shuffle] = tangling_trial

ds = dir('N:\benjamka\events\data\figure-eight\tangling');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_trial = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'trial'}, 1, length(names)), 'uniformoutput', false)));
inds_shuffle = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'_sh'}, 1, length(names)), 'uniformoutput', false)));
actual_names = names(inds_trial & ~inds_shuffle);
shuffle_names = names(inds_trial & inds_shuffle);

Q_pool = [];
for i = 1:length(actual_names)
    load(fullfile(ds(1).folder, actual_names{i}))
    Q_pool = [Q_pool, nanmean(all_Q(:))];
end

Q_pool_shuffle = [];
for i = 1:length(shuffle_names)
    load(fullfile(ds(1).folder, shuffle_names{i}))
    Q_pool_shuffle = [Q_pool_shuffle, nanmean(all_Q(:))];
end

figure, hold on

COLOR = 'k';
plot(1:2, [Q_pool; Q_pool_shuffle], '-', 'color', COLOR, 'linew', 1)
plot(1:2, [nanmean(Q_pool), nanmean(Q_pool_shuffle)] , 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
err1 = nanstd(Q_pool) / sqrt(sum(~isnan(Q_pool)));
err2 = nanstd(Q_pool_shuffle) / sqrt(sum(~isnan(Q_pool_shuffle)));
errorbar(1:2, [nanmean(Q_pool), nanmean(Q_pool_shuffle)],[err1, err2] , 'color', COLOR, 'linew', 2)

load figp
fixPlot(1:2, {'Actual', 'Shuffle'}, '', 'Tangling')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)