
function f8_multiplexing

load('N:\benjamka\events\data\figure-eight\multiplexing.mat')

figure, hold on

COLOR = 'k';
plot(1, nanmean(pval_all), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1, nanmean(pval_all), nanstd(pval_all) / sqrt(sum(~isnan(pval_all))), 'color', COLOR, 'linew', 2)
plotSpread(pval_all', 'xvalues', 1, 'distributionColors', COLOR)

load figp
fixPlot(1, '', '', 'Chi-square p value')
xlim([0.5, 1.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

plot(get(gca, 'xlim'), [0.05, 0.05], 'k:')