

function obj_heatmap

%%
load('N:\benjamka\events\data\event-manipulation\smat_n_hemlock_02-10_14-01.mat')
load('N:\benjamka\events\data\event-manipulation\traj_speed_hemlock_02-10_14-01.mat')

clear resp
ind = 59;
resp = smat_n(:, ind) - smat_n(:, ind-1);
[~, sortObj] = sort(resp, 'descend');

figure('pos', [381    42   547   774])
shift_win = 3;
imagesc(smat_n(sortObj, (ind-shift_win):(ind+shift_win)))

cbar = colorbar;
cbar.Label.String = 'Firing rate';
cbar.Ticks = [min(clim), max(clim)];
cbar.TickLabels = {'Min', 'Max'};
fixPlot(2:2:7, {'-20', '0', '20'}, 'Time to contact (sec)', 'Sorted neurons')
set(gca,'fontsize', 24)