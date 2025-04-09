function f8_trial_number_decoding_ensemble_impact

load('N:\benjamka\events\figures\fast-dynamics\supp\decoder_ensemble_impact.mat')
figure, hold on
COLOR = 'k';
plot(1:3, nanmean(decoder_ensemble), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1:3, nanmean(decoder_ensemble), nanstd(decoder_ensemble) / sqrt(5), 'color', COLOR, 'linew', 2)
plotSpread(decoder_ensemble, 'distributionColors', COLOR)
set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)
load figp
set(gcf,'pos',figp), movegui
rotateXLabels(gca, 30)
axis([0.5 3.5 3 8])
fixPlot('', {'Boundary', 'Other', 'Random'}, '', sprintf('Decoding error\n(# of trials)'))
set(gca,'fontsize', 24)
p = anova_rm({decoder_ensemble});