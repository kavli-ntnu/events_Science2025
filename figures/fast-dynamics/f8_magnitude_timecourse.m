

function res = f8_magnitude_timecourse

ds = dir('N:\benjamka\events\data\figure-eight\fastDynamics');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds);

res = nan(5, 6);
for iSession = 1:length(smat_names)
    load(fullfile(ds(1).folder, smat_names{iSession}))
    smat_trial_ave = epoch_ave(smat_n, epochs);
    [~, max_ind] = max(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);
    [~, min_ind] = min(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);

    for iIter = 1:6
        shift_ind = iIter;
        mod_cells = smat_trial_ave((max_ind == shift_ind) | (min_ind == shift_ind), 1:7);
        res(iSession, iIter) = nanmean(abs(mod_cells(:, iIter+1) - mod_cells(:, iIter)));
    end
end

figure, hold on
COLOR = 'k';
errorbar(nanmean(res), nanstd(res, [], 1) / sqrt(size(res, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
plot([3, 3], [0 0.14], 'k-', 'linew', 1)
set(gcf, 'pos', [494   165   422   590]), movegui
fixPlot([1, 3, 5], num2str([-2, 0, 2]'), 'Preferred time (sec)', 'Absolute rate change')
xlim([0.5, 6.5])
ylim([0.04 0.14])
set(gca,'fontsize', 24)