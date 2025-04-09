
function f8_trial_number_decoding_time_impact

load('N:\benjamka\events\figures\fast-dynamics\supp\decoder_time_impact.mat')
figure, hold on
COLOR = 'k';
plot(1:7, nanmean(decoder_impact), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1:7, nanmean(decoder_impact), nanstd(decoder_impact) / sqrt(5), 'color', COLOR, 'linew', 2)
plotSpread(decoder_impact, 'distributionColors', COLOR)
set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)
load figp
set(gcf,'pos',figp), movegui
rotateXLabels(gca, 0)
ylim([-0.5 1.2])
fixPlot('', [], 'Trial time (sec)', sprintf('\\Delta decoding error\n(# of trials)'))
set(gca,'fontsize', 24)
p = anova_rm({decoder_impact});