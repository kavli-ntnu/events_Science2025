

function Q_all = tangling(regions, colors)

figure, hold on

for iRegion = 1:length(regions)

    Q_pool = [];
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\tangling_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            Q = tmp.Q;
        else
            break
        end
        Q_pool = [Q_pool, nanmean(Q)]; % mean tangling for trajectory
    end

    % store vals
    tmp = Q_pool;
    Q_all{iRegion} = tmp(~isnan(tmp));
end

Q_sh_pool = [];
for iRegion = 1:length(regions)
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\tangling_%ssh_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            Q_sh = tmp.Q;
        else
            break
        end
        Q_sh_pool = [Q_sh_pool, nanmean(Q_sh)];
    end
end
% store vals
tmp = Q_sh_pool;
Q_all{end + 1} = tmp(~isnan(tmp));

for iGroup = 1:size(colors, 1)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(Q_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(Q_all{iGroup}), nanstd(Q_all{iGroup}) / sqrt(sum(~isnan(Q_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(Q_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(colors, 1), [regions(1:3), 'Shuffle'], '', 'Tangling')
xlim([0.5, size(colors, 1) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)