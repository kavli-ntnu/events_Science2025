

function [Q_all, Q_all_shuffle] = tangling_session

ds = dir('N:\benjamka\events\data\figure-eight\tangling');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_session = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'session'}, 1, length(names)), 'uniformoutput', false)));
inds_shuffle = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'_sh'}, 1, length(names)), 'uniformoutput', false)));
actual_names = names(inds_session & ~inds_shuffle);
shuffle_names = names(inds_session & inds_shuffle);

Q_all = [];
for i = 1:length(actual_names)
    load(fullfile(ds(1).folder, actual_names{i}))
    Q_all = [Q_all, nanmean(Q)];
end

Q_all_shuffle = [];
for i = 1:length(shuffle_names)
    load(fullfile(ds(1).folder, shuffle_names{i}))
    Q_all_shuffle = [Q_all_shuffle, nanmean(Q)];
end

figure, hold on

COLOR = 'k';
plot(1:2, [Q_all; Q_all_shuffle], '-', 'color', COLOR, 'linew', 1)
plot(1:2, [nanmean(Q_all), nanmean(Q_all_shuffle)] , 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
err1 = nanstd(Q_all) / sqrt(sum(~isnan(Q_all)));
err2 = nanstd(Q_all_shuffle) / sqrt(sum(~isnan(Q_all_shuffle)));
errorbar(1:2, [nanmean(Q_all), nanmean(Q_all_shuffle)],[err1, err2] , 'color', COLOR, 'linew', 2)

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:2, {'Actual', 'Shuffle'}, '', 'Tangling within session')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)