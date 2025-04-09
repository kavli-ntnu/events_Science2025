
function [mean_rate_obj, mean_rate_other] = pop_rate_obj

ds = dir('N:\benjamka\events\data\event-manipulation');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj);
inds_smat = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds_smat);

mean_rate_obj = [];
mean_rate_other = [];
rng('default')
for i = [2, 3, 5, 6, 7, 8, 9, 10] % exclude sessions where multiple objects were ignored or insufficient cell yield
    load(fullfile(ds(1).folder, traj_names{i}))
    load(fullfile(ds(1).folder, smat_names{i}))

    mean_rate_obj = [mean_rate_obj, sum(smat_n(:, ismember(timeInt(1:end-1), near_times))) / size(smat_n, 1)];
    n_rand = sum(ismember(timeInt(1:end-1), near_times));
    rand_inds = find(~ismember(timeInt(1:end-1), near_times));
    rand_inds = rand_inds(randperm(length(rand_inds), n_rand));
    mean_rate_other = [mean_rate_other, sum(smat_n(:, rand_inds)) / size(smat_n, 1)];
end

figure
hold on

COLOR = 'k';
plot(1, nanmean(mean_rate_obj), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1, nanmean(mean_rate_obj), nanstd(mean_rate_obj) / sqrt(sum(~isnan(mean_rate_obj))), 'color', COLOR, 'linew', 2)
plotSpread(mean_rate_obj', 'xvalues', 1, 'distributionColors', COLOR)

COLOR = [0.5 0.5 0.5];
plot(2, nanmean(mean_rate_other), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(2, nanmean(mean_rate_other), nanstd(mean_rate_other) / sqrt(sum(~isnan(mean_rate_other))), 'color', COLOR, 'linew', 2)
plotSpread(mean_rate_other', 'xvalues', 2, 'distributionColors', COLOR)

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

fixPlot(1:2, {'OBJ', 'Other'}, '', 'Norm. firing rate')
set(gca, 'fontsize', 24)
load figp
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) * 0.67;
set(gcf,'pos',figp_skinny), movegui
xlim([0.5 2.5])
rotateXLabels(gca, 0)
