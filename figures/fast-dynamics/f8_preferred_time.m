

function peak_percent = f8_preferred_time

ds = dir('N:\benjamka\events\data\figure-eight\fastDynamics');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds);

for iIter = 1:6
    shift_ind = iIter;
    tmp_percent = nan(5, 2);
    for iSession = 1:length(smat_names)
        load(fullfile(ds(1).folder, smat_names{iSession}))
        smat_trial_ave = epoch_ave(smat_n, epochs);
        [~, max_ind] = max(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);
        [~, min_ind] = min(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);
        tmp_percent(iSession, 1) = sum(max_ind == shift_ind) / size(smat_trial_ave, 1);
        tmp_percent(iSession, 2) = sum(min_ind == shift_ind) / size(smat_trial_ave, 1);
    end
    tmp_percent = mean(tmp_percent, 2);
    peak_percent(:, iIter) = tmp_percent; 
end

figure, hold on
COLOR = 'k';
errorbar(nanmean(peak_percent), nanstd(peak_percent, [], 1) / sqrt(size(peak_percent, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
plot([0, 7], [1/6, 1/6], 'k-', 'linew', 1)
plot([3, 3], [0 1], 'k-', 'linew', 1)
set(gcf, 'pos', [494   165   422   590]), movegui
fixPlot([1, 3, 5], num2str([-2, 0, 2]'), 'Preferred time (sec)', 'Fraction of neurons')
xlim([0.5, 6.5])
ylim([0 0.3])
set(gca,'fontsize', 24)
