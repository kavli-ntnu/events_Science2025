

function corr_all = spike_amplitude(regions, colors)

figure, hold on
clear corr_pool
for iRegion = 1:length(regions)
    corr_pool = [];
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\spike_amplitudes_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            first = tmp.first;
            last = tmp.last;
        else
            break
        end
        corr_pool = [corr_pool, corr(first', last')];
    end

    % store vals
    tmp = corr_pool;
    corr_all{iRegion} = tmp(~isnan(tmp));
end

corr_sh_pool = [];
for iRegion = 1:length(regions)
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\spike_amplitudes_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            first = tmp.first;
            last = tmp.last;
        else
            break
        end
        corr_sh_pool = [corr_sh_pool, corr(first(randperm(length(first), length(first)))', last')];
    end
end
% store vals
tmp = corr_sh_pool;
corr_all{end + 1} = tmp(~isnan(tmp));

for iGroup = 1:size(colors, 1)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(corr_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(corr_all{iGroup}), nanstd(corr_all{iGroup}) / sqrt(sum(~isnan(corr_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(corr_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(colors, 1), [regions(1:3), 'Shuffle'], '', 'Spike amplitude correlation')
xlim([0.5, size(colors, 1) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

%%
figure
load(sprintf('N:\\benjamka\\events\\data\\foraging\\spike_amplitudes_%s_%d.mat', 'LEC', 17));
subplot(131)
plot(first, last, '.', 'color', colors(1, :))
title(sprintf('LEC: R^2 = %1.2f', corr(first', last')), 'fontsize', 16, 'color', colors(1, :))
axis square
fixPlot('', [], 'Mean spike amplitude first quarter', 'Mean spike amplitude last quarter')
load(sprintf('N:\\benjamka\\events\\data\\foraging\\spike_amplitudes_%s_%d.mat', 'MEC', 8));
subplot(132)
plot(first, last, '.', 'color', colors(2, :))
title(sprintf('MEC: R^2 = %1.2f', corr(first', last')), 'fontsize', 16, 'color', colors(2, :))
axis square
fixPlot('', [], 'Mean spike amplitude first quarter', 'Mean spike amplitude last quarter')
load(sprintf('N:\\benjamka\\events\\data\\foraging\\spike_amplitudes_%s_%d.mat', 'CA1', 3));
subplot(133)
plot(first, last, '.', 'color', colors(3, :))
title(sprintf('CA1: R^2 = %1.2f', corr(first', last')), 'fontsize', 16, 'color', colors(3, :))
axis square
fixPlot('', [], 'Mean spike amplitude first quarter', 'Mean spike amplitude last quarter')
