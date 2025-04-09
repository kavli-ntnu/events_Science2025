
function [speed_first] = trajectory_speed_obj_contact

ds = dir('N:\benjamka\events\data\event-manipulation');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj);
inds_smat = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds_smat);

SIZEMATCH = 0;
if SIZEMATCH
    N_iter = 20;
    rng(666)
else
    N_iter = 1;
end

for iIter = 1:N_iter
    speed_first = [];
    speed_other = [];
    for iSession = 1:length(smat_names)
    
        load(fullfile(ds(1).folder, traj_names{iSession}))
        load(fullfile(ds(1).folder, smat_names{iSession}))
        
        if SIZEMATCH && size(smat_n, 1) >= 134
            rand_inds = datasample(1:size(smat_n, 1), 134, 'replace', false);
            smat_n = smat_n(rand_inds, :);
        end
        dists_neigh = diag(squareform(pdist(smat_n', 'cosine')), -1);

        % find first contact for each object
        inds_first_near = nan(1, 3);
        inds_first_near_ctrl = nan(1, 3);
        inds_other_near = [];
        for iObj = 1:3
            tmp = near_times((near_times > (session_obj_info(iObj + 1, 1) - 10)) & (near_times < session_obj_info(iObj + 1, 2))); % -10 is a single bin in case contact is immediate
            if ~isempty(tmp)
                [~, mind] = min(abs(timeInt - tmp(1)));
                inds_first_near(iObj) = mind;
                [~, mind] = min(abs(timeInt - (tmp(1) - (session_obj_info(iObj + 1, 1) - 10))));
                inds_first_near_ctrl(iObj) = mind;
                tmp2 = knnsearch(timeInt', tmp');
                inds_other_near = [inds_other_near; tmp2(find(diff(tmp2) > 1) + 1)]; % has to leave and come back
            end
        end
        inds_first_near(isnan(inds_first_near)) = [];
    
        % exclude sessions where multiple objects were ignored or insufficient cell yield
        if length(inds_first_near) < 2 || size(smat_n, 1) < 100
            % disp(iSession)
            continue
        end
        
        traj_speed = diff(dists_neigh);
    
        shift_win = 2;
        tmp = nan(length(inds_first_near), (shift_win * 2) + 1);
        for iContact = 1:length(inds_first_near)
            try
                tmp(iContact, :) = traj_speed((inds_first_near(iContact) - 2 - shift_win):(inds_first_near(iContact) - 2 + shift_win)); %  -2 is for diff correction
            end
        end
        speed_first = [speed_first; tmp];
    
        traj_speed = diff(dists_neigh);
        tmp = nan(length(inds_other_near), (shift_win * 2) + 1);
        for iContact = 1:length(inds_other_near)
            try
                tmp(iContact, :) = traj_speed((inds_other_near(iContact) - 2 - shift_win):(inds_other_near(iContact) - 2 + shift_win ));
            end
        end
        speed_other = [speed_other; tmp];
    end
    
    speed_first_iter(:, :, iIter) = speed_first;
    speed_other_iter(:, :, iIter) = speed_other;
end
if SIZEMATCH
    speed_first = nanmean(speed_first_iter, 3);
    speed_other = nanmean(speed_other_iter, 3);
end

% speed_first = speed_other; % isolate later contacts
figure, hold on
COLOR = 'k';
% COLOR = [0, 0, 0.8];
% COLOR = [0, 0.4, 0];
errorbar(nanmean(speed_first, 1), nanstd(speed_first, [], 1) / sqrt(size(speed_first, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
set(gcf, 'pos', [501   158   448   590]), movegui
fixPlot(1:2:5, {'-20', '0', '20'}, 'Time to contact (sec)', 'Change in trajectory speed')
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