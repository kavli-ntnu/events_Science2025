
function [session_wn, trial_wn, session_trial_bn] = angular_offset

load('N:\benjamka\events\data\figure-eight\angular_offset.mat')
session_wn = angles_wn_session;
trial_wn = angles_wn_trial;
session_trial_bn = angles_bn;

figure, hold on

COLOR = 'k';
plot(3, nanmean(session_wn), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(3, nanmean(session_wn), nanstd(session_wn) / sqrt(sum(~isnan(session_wn))), 'color', COLOR, 'linew', 2)
plotSpread({session_wn}, 'xvalues', 3, 'distributionColors', COLOR)

plot(2, nanmean(trial_wn), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(2, nanmean(trial_wn), nanstd(trial_wn) / sqrt(sum(~isnan(trial_wn))), 'color', COLOR, 'linew', 2)
plotSpread({trial_wn}, 'xvalues', 2, 'distributionColors', COLOR)

plot(1, nanmean(session_trial_bn), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1, nanmean(session_trial_bn), nanstd(session_trial_bn) / sqrt(sum(~isnan(session_trial_bn))), 'color', COLOR, 'linew', 2)
plotSpread({session_trial_bn}, 'xvalues', 1, 'distributionColors', COLOR)

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:3, {'Session vs Trial', 'Within Trial', 'Within Session'}, '', 'Angular offset (deg)')
set(gca, 'ytick', 0:30:90)
xlim([0.5, 3.5])
ylim([0, 90])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
