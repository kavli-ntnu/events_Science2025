

function dists_all = distance_traveled(regions, colors)

figure, hold on
clear dists_pool
for iRegion = 1:length(regions)
    dists_pool = [];
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\dists_endpt_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            dists = tmp.dists_full;
        else
            break
        end
        dists_pool = [dists_pool, dists(end, 1)];
    end

    % store vals
    tmp = dists_pool;
    dists_all{iRegion} = tmp(~isnan(tmp));
end

dists_sh_pool = [];
for iRegion = 1%:length(regions)
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\dists_neigh_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            dists_sh = tmp.dists_full;
        else
            break
        end
        dists_sh_pool = [dists_sh_pool, dists_sh(end, 1)];
    end
end
% store vals
tmp = dists_sh_pool;
dists_all{end + 1} = tmp(~isnan(tmp));

for iGroup = 1:size(colors, 1)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(dists_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(dists_all{iGroup}), nanstd(dists_all{iGroup}) / sqrt(sum(~isnan(dists_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(dists_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(colors, 1), [regions(1:3), 'LEC neighbor'], '', 'Distance traveled')
xlim([0.5, size(colors, 1) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)