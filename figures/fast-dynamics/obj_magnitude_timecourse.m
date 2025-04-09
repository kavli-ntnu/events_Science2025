
function res = obj_magnitude_timecourse

ds = dir('N:\benjamka\events\data\event-manipulation');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj);
inds_smat = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds_smat);

res = nan(length(traj_names), 4);
for iSession = 1:length(traj_names)
    load(fullfile(ds(1).folder, traj_names{iSession}))
    load(fullfile(ds(1).folder, smat_names{iSession}))

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

    shift_win = 2;
    tmp = nan(size(smat_n, 1), (shift_win * 2) + 1, length(inds_first_near));
    for iContact = 1:length(inds_first_near)
        tmp(:, :, iContact) = smat_n(:, (inds_first_near(iContact) - shift_win):(inds_first_near(iContact) + shift_win));
    end

    smat_trial_ave = nanmean(tmp, 3);
    [~, max_ind] = max(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);
    [~, min_ind] = min(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);
    for iIter = 1:4
        shift_ind = iIter;
        mod_cells = smat_trial_ave((max_ind == shift_ind) | (min_ind == shift_ind), 1:5);
        res(iSession, iIter) = nanmean(abs(mod_cells(:, iIter+1) - mod_cells(:, iIter)));
    end
end

figure, hold on
COLOR = 'k';
errorbar(nanmean(res), nanstd(res, [], 1) / sqrt(size(res, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
plot([2, 2], [0 0.2], 'k-', 'linew', 1)
set(gcf, 'pos', [494   165   422   590]), movegui
fixPlot([2], num2str([0]'), 'Preferred time (sec)', 'Absolute rate change')
xlim([0.5, 4.5])
ylim([0.1 0.16])
set(gca,'fontsize', 24)