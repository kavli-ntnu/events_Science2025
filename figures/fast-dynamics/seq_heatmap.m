

function seq_heatmap

load('N:\benjamka\events\data\sequence\smat_n_trial_elm_07-01_12-24.mat')

smat_epoch_ave = epoch_ave(smat_n, epochs);
[~, sortInd] = sort(smat_epoch_ave(:, 12) - smat_epoch_ave(:, 11), 'descend');

figure('pos', [381    42   547   774])
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot(2:10:32, num2str([-10:10:32]'), 'Time to shift (sec)', 'Sorted neurons')
xlim([0.5, 32.5])
set(gca,'fontsize', 24)

return

%% cross val

starts = epochs == 1;

midpt = find(starts, 7);
midpt = midpt(end) - 1;
train_inds = logical([ones(1, midpt), zeros(1, length(epochs) - midpt)]);
test_inds = ~train_inds;

% figure
% subplot(221)
figure('pos', [381    42   547   774])
smat_epoch_ave = epoch_ave(smat_n(:, train_inds), epochs(train_inds));
[~, sortInd] = sort(smat_epoch_ave(:, 12) - smat_epoch_ave(:, 11), 'descend');
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot(2:10:32, num2str([-10:10:32]'), 'Time to shift (sec)', 'Sorted neurons')
xlim([0.5, 32.5])
title('First (sort first)')
set(gca,'fontsize', 24)

% subplot(222)
figure('pos', [381    42   547   774])
smat_epoch_ave = epoch_ave(smat_n(:, train_inds), epochs(train_inds));
[~, sortInd] = sort(smat_epoch_ave(:, 12) - smat_epoch_ave(:, 11), 'descend');
smat_epoch_ave = epoch_ave(smat_n(:, test_inds), epochs(test_inds));
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot(2:10:32, num2str([-10:10:32]'), 'Time to shift (sec)', '')
xlim([0.5, 32.5])
title('Second (sort first)')
set(gca,'fontsize', 24)

% subplot(223)
figure('pos', [381    42   547   774])
smat_epoch_ave = epoch_ave(smat_n(:, test_inds), epochs(test_inds));
[~, sortInd] = sort(smat_epoch_ave(:, 12) - smat_epoch_ave(:, 11), 'descend');
smat_epoch_ave = epoch_ave(smat_n(:, train_inds), epochs(train_inds));
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot(2:10:32, num2str([-10:10:32]'), 'Time to shift (sec)', 'Sorted neurons')
xlim([0.5, 32.5])
title('First (sort second)')
set(gca,'fontsize', 24)

% subplot(224)
figure('pos', [381    42   547   774])
smat_epoch_ave = epoch_ave(smat_n(:, test_inds), epochs(test_inds));
[~, sortInd] = sort(smat_epoch_ave(:, 12) - smat_epoch_ave(:, 11), 'descend');
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot(2:10:32, num2str([-10:10:32]'), 'Time to shift (sec)', '')
xlim([0.5, 32.5])
title('Second (sort second)')
set(gca,'fontsize', 24)
