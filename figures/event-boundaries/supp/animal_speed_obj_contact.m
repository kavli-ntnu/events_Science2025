
function [speed_first, speed_other] = animal_speed_obj_contact

ds = dir('N:\benjamka\events\data\event-manipulation');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj);
inds_smat = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds_smat);

speed_first = [];
speed_shuffle = [];
speed_other = [];

rng(666)
n_iter = 20;

for iSession = [2, 3, 5, 6, 7, 8, 9, 10] % exclude sessions where objects are ignored due to motivation issues or less than 100 cells
    load(fullfile(ds(1).folder, traj_names{iSession}))
    load(fullfile(ds(1).folder, smat_names{iSession}))
    tmp = smat_names{iSession};
    tmp = strrep(tmp, 'smat_n', 'smat_spd');
    load(fullfile(ds(1).folder, tmp))

    dists_neigh = diag(squareform(pdist(smat_n', 'cosine')), -1);

    inds_near = ismember(timeInt(1:end-1), near_times);
    diff_inds = [nan, diff(inds_near)];
    inds_first_near = find(inds_near == 1 & diff_inds == 1);

    % find first contact for each object
    inds_first_near = nan(1, 3);
    inds_other_near = [];
    for iObj = 1:3
        tmp = near_times((near_times > (session_obj_info(iObj + 1, 1) - 10)) & (near_times < session_obj_info(iObj + 1, 2)));
        if ~isempty(tmp)
            [~, mind] = min(abs(timeInt - tmp(1)));
            inds_first_near(iObj) = mind;
            tmp2 = knnsearch(timeInt', tmp');
            inds_other_near = [inds_other_near; tmp2(find(diff(tmp2) > 1) + 1)]; % has to leave and come back
        end
    end
    inds_first_near(isnan(inds_first_near)) = [];

    traj_speed = diff(smat_spd);

    shift_win = 2;
    tmp = nan(length(inds_first_near), (shift_win * 2) + 1);
    for iContact = 1:length(inds_first_near)
        try
            tmp(iContact, :) = traj_speed((inds_first_near(iContact) - 2 - shift_win):(inds_first_near(iContact) - 2 + shift_win)); %  -2 is for diff correction
        end
    end
    speed_first = [speed_first; tmp];

    traj_speed = diff(smat_spd);

    tmp = nan(length(inds_other_near), (shift_win * 2) + 1);
    for iContact = 1:length(inds_other_near)
        try
            tmp(iContact, :) = traj_speed((inds_other_near(iContact) - 2 - shift_win):(inds_other_near(iContact) - 2 + shift_win ));
        end
    end
    speed_other = [speed_other; tmp];

end
figure, hold on
COLOR = 'k';
errorbar(nanmean(speed_first, 1), nanstd(speed_first, [], 1) / sqrt(size(speed_first, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
set(gcf, 'pos', [501   158   448   590]), movegui
fixPlot(1:2:5, {'-20', '0', '20'}, 'Time to contact (sec)', 'Change in animal speed (m/s^2)')
xlim([0.5, size(speed_first, 2) + 0.5])
ylim([-0.05, 0.05])
set(gca, 'YTick', [-0.05, 0, 0.05])
plot(xlim, [0, 0], 'k:')
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

return

%% save traj info
thresh = 90;
clear df
for i = 2:size(smat_n, 2)
    df(i-1) = sum(smat_n(:, i) - smat_n(:, i - 1));
end
df = df / size(smat_n, 1);
rate_change_inds = find(mean(smat_n(:, 2:end), 1) > prctile(mean(smat_n(:, 2:end), 1), thresh) & df > prctile(df, thresh));
rate_change_times = timeInt(rate_change_inds + 1);

% load dists_neigh.mat
dists_neigh = diag(squareform(pdist(smat_n', 'cosine')), -1);
traj_speed = diff(dists_neigh);
traj_speed_rateChange = nan(length(rate_change_inds), 13);
for i = 1:length(rate_change_inds)
    if ((rate_change_inds(i) - 7) > 0) && ((rate_change_inds(i) + 5) <= length(traj_speed))
        tmp_inds = (rate_change_inds(i) - 7):(rate_change_inds(i) + 5);
        tmp_inds = tmp_inds(tmp_inds <= length(traj_speed));
        traj_speed_rateChange(i, 1:length(tmp_inds)) = traj_speed(tmp_inds);
    end
end

obj_thresh = 0.1; % distance in meters
obj_first = nan(1, length(timeInt) - 1);
obj_ave = nan(1, length(timeInt) - 1);
for i = 1:length(timeInt)-1
    if timeInt(i) + 5 >= session_obj_info(2, 1) && timeInt(i) < session_obj_info(2, 2)
        sesh_window = 2;
    elseif timeInt(i) + 5 >= session_obj_info(3, 1) && timeInt(i) < session_obj_info(3, 2)
        sesh_window = 3;
    elseif timeInt(i) + 5 >= session_obj_info(4, 1) && timeInt(i) < session_obj_info(4, 2)
        sesh_window = 4;
    else
        sesh_window = 1;
    end
    if sesh_window > 1
        t_inds = posT >= timeInt(i) & posT < timeInt(i + 1);
        obj_near = (abs(posX(t_inds) - session_obj_info(sesh_window, 3)) < obj_thresh) & (abs(posY(t_inds) - session_obj_info(sesh_window, 4)) < obj_thresh);
        try
            obj_first(i) = timeInt(i) + (1/120 * find(obj_near, 1));
        end
        obj_ave(i) = any(obj_near);
    end
end
near_times = timeInt(obj_ave > 0);
% find first contact for each object
inds_first_near = nan(1, 3);
for iObj = 1:3
    tmp = near_times((near_times > session_obj_info(iObj + 1, 1)) & (near_times < session_obj_info(iObj + 1, 2)));
    if ~isempty(tmp)
        [~, mind] = min(abs(timeInt - tmp(1)));
        inds_first_near(iObj) = mind;
    end
end
inds_first_near(isnan(inds_first_near)) = [];

shift_win = 3;
tmp = nan(length(inds_first_near), (shift_win * 2) + 1);
for iContact = 1:length(inds_first_near)
    tmp(iContact, :) = traj_speed((inds_first_near(iContact) - 2 - shift_win):(inds_first_near(iContact) - 2 + shift_win)); %  -2 is for diff correction
end
speed_first = tmp;
figure, plot(speed_first', '.-', 'linew', 2, 'markers', 30)