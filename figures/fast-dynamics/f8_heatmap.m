

function f8_heatmap

load('N:\benjamka\events\data\figure-eight\fastDynamics\smat_n_cedar_12-15_11-47.mat')

smat_epoch_ave = epoch_ave(smat_n, epochs);
[~, sortInd] = sort(smat_epoch_ave(:, 4) - smat_epoch_ave(:, 3), 'descend');

figure('pos', [381    42   547   774])
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot([2:2:6], num2str([-2:2:2]'), 'Trial to shift (sec)', 'Sorted neurons')
xlim([0.5, 7.5])
set(gca,'fontsize', 24)

return

%% cross val

% 1st vs 2nd half
trialSecs = length(unique(epochs));
N_trials = length(epochs) / trialSecs;
train_inds = logical([ones(1, trialSecs * floor(N_trials/2)), zeros(1, trialSecs * ceil(N_trials/2))]);
test_inds = ~train_inds;

% figure
% subplot(221)
figure('pos', [381    42   547   774])
smat_epoch_ave = epoch_ave(smat_n(:, train_inds), epochs(train_inds));
[~, sortInd] = sort(smat_epoch_ave(:, 4) - smat_epoch_ave(:, 3), 'descend');
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot([2:2:6], num2str([-2:2:2]'), 'Time to shift (sec)', 'Sorted neurons')
xlim([0.5, 7.5])
title('First (sort first)')
set(gca,'fontsize', 24)

% subplot(222)
figure('pos', [381    42   547   774])
smat_epoch_ave = epoch_ave(smat_n(:, train_inds), epochs(train_inds));
[~, sortInd] = sort(smat_epoch_ave(:, 4) - smat_epoch_ave(:, 3), 'descend');
smat_epoch_ave = epoch_ave(smat_n(:, test_inds), epochs(test_inds));
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot([2:2:6], num2str([-2:2:2]'), 'Time to shift (sec)', '')
xlim([0.5, 7.5])
title('Second (sort first)')
set(gca,'fontsize', 24)

% subplot(223)
figure('pos', [381    42   547   774])
smat_epoch_ave = epoch_ave(smat_n(:, test_inds), epochs(test_inds));
[~, sortInd] = sort(smat_epoch_ave(:, 4) - smat_epoch_ave(:, 3), 'descend');
smat_epoch_ave = epoch_ave(smat_n(:, train_inds), epochs(train_inds));
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot([2:2:6], num2str([-2:2:2]'), 'Time to shift (sec)', 'Sorted neurons')
xlim([0.5, 7.5])
title('First (sort second)')
set(gca,'fontsize', 24)

% subplot(224)
figure('pos', [381    42   547   774])
smat_epoch_ave = epoch_ave(smat_n(:, test_inds), epochs(test_inds));
[~, sortInd] = sort(smat_epoch_ave(:, 4) - smat_epoch_ave(:, 3), 'descend');
imagesc(smat_epoch_ave(sortInd, :));
cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot([2:2:6], num2str([-2:2:2]'), 'Time to shift (sec)', '')
xlim([0.5, 7.5])
title('Second (sort second)')
set(gca,'fontsize', 24)
