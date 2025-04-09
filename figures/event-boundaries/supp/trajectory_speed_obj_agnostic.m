
function [speed_sync, speed_rand] = trajectory_speed_obj_agnostic

ds = dir('N:\benjamka\events\data\event-manipulation');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj);
inds_smat = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds_smat);

O_XY_pool = [];
O_XnY_pool = [];
O_nXY_pool = [];
O_nXnY_pool = [];
speed_sync = [];
for iSession = [2, 3, 5, 6, 7, 8, 9, 10] % exclude sessions where objects are ignored due to motivation issues
    load(fullfile(ds(1).folder, traj_names{iSession}))
    load(fullfile(ds(1).folder, smat_names{iSession}))

    inds = rate_change_times > session_obj_info(2, 1); % limit to times when objects could be present
    traj_speed_rateChange = traj_speed_rateChange(inds, :);

    % select (no) object times
    fraction_obj = sum(ismember(rate_change_times(inds), near_times)) / sum(inds);
    fprintf('%.2f ', fraction_obj)

    % Observed values (X is sync times, Y is near times)
    O_XY = sum(ismember(rate_change_times(inds), near_times));
    O_XnY = sum(inds) - O_XY;
    O_nXY = length(near_times) - O_XY;
    O_nXnY = (sum(timeInt > session_obj_info(2, 1)) - 1) - O_XnY - O_nXY;

    speed_sync = [speed_sync; traj_speed_rateChange];

    O_XY_pool = [O_XY_pool, O_XY];
    O_XnY_pool = [O_XnY_pool, O_XnY];
    O_nXY_pool = [O_nXY_pool, O_nXY];
    O_nXnY_pool = [O_nXnY_pool, O_nXnY];
end

table = [sum(O_XY_pool), sum(O_XnY_pool); sum(O_nXY_pool), sum(O_nXnY_pool)];

% Fisher’s Exact Test
[h, p] = fishertest(table);
disp(['Fisher’s Exact Test p-value: ', num2str(p)]);

%%

% random indices
rng('default')
speed_rand = [];
cnt = 1;
for iSession = [2, 3, 5, 6, 7, 8, 9, 10] % exclude sessions where objects are ignored due to motivation issues
    load(fullfile(ds(1).folder, traj_names{iSession}))
    load(fullfile(ds(1).folder, smat_names{iSession}))

    traj_speed_sh = diff(dists_neigh);

    n_inds = sum(rate_change_times > session_obj_info(2, 1));
    
    for k = 1:n_inds
        tmp_speed = [];
        for j = 1:20
            tmp_ind = randi([7, length(traj_speed_sh) - 7]);
            tmp_speed(j, :) = traj_speed_sh(tmp_ind - 6:tmp_ind + 6);
        end
        speed_rand(cnt, :) = mean(tmp_speed);
        cnt = cnt + 1;
    end
end

speed_sync = speed_sync(:, 5:9);
speed_rand = speed_rand(:, 5:9);

figure, hold on

COLOR = [0.5 0.5 0.5];
errorbar(nanmean(speed_rand, 1), nanstd(speed_rand, [], 1) / sqrt(size(speed_rand, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
COLOR = 'k';
errorbar(nanmean(speed_sync, 1), nanstd(speed_sync, [], 1) / sqrt(size(speed_sync, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)

set(gcf, 'pos', [501   158   448   590]), movegui
fixPlot(1:5, num2str([-20:10:20]'), 'Time (sec)', 'Change in trajectory speed')
xlim([0.5, size(speed_sync, 2) + 0.5])
ylim([-0.065, 0.065])
set(gca, 'YTick', [-0.06, 0, 0.06])
plot(xlim, [0, 0], 'k:')
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

sh_cutoffs = prctile(speed_rand(:), [1, 99]);
h = patch([xlim, fliplr(xlim)], [sh_cutoffs(1), sh_cutoffs(1), sh_cutoffs(2), sh_cutoffs(2)], [0.5, 0.5, 0.5], 'facealpha', 1, 'lines', 'none');
uistack(h, 'bottom')
