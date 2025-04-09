

function [tangling_REM, tangling_of] = tangling

xl = readcell('N:\benjamka\events\data\sleep\raw_data4ben2\OFvsREM_LDA-tangling_True-labels_1000ms-bin_v2.csv');
% xl = readcell('N:\benjamka\events\data\sleep\raw_data4ben_CA1-MEC\OFvsREM_LDA-tangling_True-labels_1000ms-bin_MEC_fv.csv');
% xl = readcell('N:\benjamka\events\data\sleep\raw_data4ben_CA1-MEC\OFvsREM_LDA-tangling_True-labels_1000ms-bin_CA1_fv.csv');
labels = xl(1, :);
xl = xl(2:end, :);

tangling_of = cell2mat(extract.cols(xl, labels, 'OF'));
tangling_REM = cell2mat(extract.cols(xl, labels, 'REM'));

figure
hold on

COLOR = 'k';
plot(1, nanmean(tangling_REM), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1, nanmean(tangling_REM), nanstd(tangling_REM) / sqrt(sum(~isnan(tangling_REM))), 'color', COLOR, 'linew', 2)
plotSpread({tangling_REM}, 'xvalues', 1, 'distributionColors', COLOR)

plot(2, nanmean(tangling_of), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(2, nanmean(tangling_of), nanstd(tangling_of) / sqrt(sum(~isnan(tangling_of))), 'color', COLOR, 'linew', 2)
plotSpread({tangling_of}, 'xvalues', 2, 'distributionColors', COLOR)

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:2, {'REM', 'Foraging'}, '', 'Trajectory tangling')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) * 0.67;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)