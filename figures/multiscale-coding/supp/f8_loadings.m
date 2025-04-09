
function [loadings_s, loadings_t] = f8_loadings

load('N:\benjamka\events\data\figure-eight\f8_loadings.mat')

figure, hold on
plot(abs(loadings_s), abs(loadings_t), 'k.', 'markers', 20)
thresh_s = prctile(abs(loadings_s), 75);
thresh_t = prctile(abs(loadings_t), 75);
plot([thresh_s, thresh_s], ylim(), 'k:')
plot(xlim(), [thresh_t, thresh_t], 'k:')
axis([0 0.23 0 0.23])

load figp
fixPlot('', [], 'Session time loadings', 'Trial time loadings')
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)