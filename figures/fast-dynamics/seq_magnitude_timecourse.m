

function [res, per] = seq_magnitude_timecourse

ds = dir('N:\benjamka\events\data\sequence');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n_trial'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds);

res = nan(5, 28);
cnt = 0;
for iSession = [1:4, 10] % match behavior across rats
    cnt = cnt + 1;
    load(fullfile(ds(1).folder, smat_names{iSession}))
    smat_trial_ave = epoch_ave(smat_n, epochs);
    [~, max_ind] = max(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);
    [~, min_ind] = min(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);

    for iIter = 1:28
        shift_ind = iIter;

        mod_cells = smat_trial_ave((max_ind == shift_ind) | (min_ind == shift_ind), 1:29);
        res(cnt, iIter) = nanmean(abs(mod_cells(:, iIter+1) - mod_cells(:, iIter)));
        per(iIter) = size(mod_cells, 1) / size(smat_trial_ave, 1);
    end
end

figure, hold on
COLOR = 'k';
errorbar(nanmean(res), nanstd(res, [], 1) / sqrt(size(res, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
plot([11, 11], [0 0.14], 'k-', 'linew', 1)
load figp
set(gcf, 'pos', figp), movegui
fixPlot([1, 11, 21], num2str([-10, 0, 10]'), 'Time to shift (sec)', 'Absolute rate change')
xlim([0.5, 29.5])
ylim([0.06 0.14])
set(gca,'fontsize', 24)