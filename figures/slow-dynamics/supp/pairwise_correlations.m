
function pairwise_correlations

regions = {'LEC', 'MEC', 'CA1'};
colors = [0, 0, 0; 0, 0, 0.8; 0, 0.4, 0; 0.5, 0.5, 0.5];

% examples from 'N:\spacetime\time\27285_Elm\2021-06-30_13-58-39'
load('N:\benjamka\events\data\foraging\corr_mat_examples.mat')

figure('position', [272, 42, 314, 774])
hold on
edges = -1:0.1:1;
xvals = edges(1:end-1) + min(diff(edges)) / 2;

subplot(311)
cnts = histcounts(corr_mat_LEC(:), edges);
bar(xvals, cnts / sum(cnts), 'facecolor', colors(1, :))
fixPlot(-1:0.5:1, [], 'Pairwise correlation', 'Proportion')
axis([-1, 1, 0, 0.1])
subplot(312)
cnts = histcounts(corr_mat_MEC(:), edges);
bar(xvals, cnts / sum(cnts), 'facecolor', colors(2, :))
fixPlot(-1:0.5:1, [], 'Pairwise correlation', 'Proportion')
axis([-1, 1, 0, 0.1])
subplot(313)
cnts = histcounts(corr_mat_CA1(:), edges);
bar(xvals, cnts / sum(cnts), 'facecolor', colors(3, :))
fixPlot(-1:0.5:1, [], 'Pairwise correlation', 'Proportion')
axis([-1, 1, 0, 0.1])

corr_all = corr_structure(regions, colors);