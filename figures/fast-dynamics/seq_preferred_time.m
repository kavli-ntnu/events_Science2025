

function peak_percent = seq_preferred_time

ds = dir('N:\benjamka\events\data\sequence');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n_trial'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds);

for iIter = 1:28
    shift_ind = iIter;
    tmp_percent = nan(4, 2);
    cnt = 0;
    for iSession = [1:4, 10] % match behavior across rats
        cnt = cnt + 1;
        load(fullfile(ds(1).folder, smat_names{iSession}))
        smat_trial_ave = epoch_ave(smat_n, epochs);
        [~, max_ind] = max(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);
        [~, min_ind] = min(smat_trial_ave(:, 2:end) - smat_trial_ave(:, 1:end-1), [], 2);
        tmp_percent(cnt, 1) = sum(max_ind == shift_ind) / size(smat_trial_ave, 1);
        tmp_percent(cnt, 2) = sum(min_ind == shift_ind) / size(smat_trial_ave, 1);
    end
    tmp_percent = mean(tmp_percent, 2);
    peak_percent(:, iIter) = tmp_percent; 
end

figure, hold on
COLOR = 'k';
errorbar(nanmean(peak_percent), nanstd(peak_percent, [], 1) / sqrt(size(peak_percent, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
plot([0, 29], [1/28, 1/28], 'k-', 'linew', 1)
plot([11, 11], [0 1], 'b-', 'linew', 1)
load figp
set(gcf, 'pos', figp), movegui
fixPlot([1, 11, 21], num2str([-10, 0, 10]'), 'Time to shift (sec)', 'Fraction of neurons')
xlim([0.5, 29.5])
ylim([0 0.1])
set(gca,'fontsize', 24)
