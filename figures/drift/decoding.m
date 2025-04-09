

function acc_all = decoding(regions, colors)

figure, hold on

for iRegion = 1:length(regions)

    acc_pool = [];
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\accFull_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            acc = tmp.acc;
        else
            break
        end
        acc_pool = [acc_pool, acc];
    end

    % store vals
    tmp = acc_pool;
    acc_all{iRegion} = tmp(~isnan(tmp));
end

acc_sh_pool = [];
for iRegion = 1:length(regions)
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\accFull_%ssh_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            acc_sh = tmp.acc;
        else
            break
        end
        acc_sh_pool = [acc_sh_pool, nanmean(acc_sh)];
    end
end
% store vals
tmp = acc_sh_pool;
acc_all{end + 1} = tmp(~isnan(tmp));

for iGroup = 1:size(colors, 1)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(acc_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(acc_all{iGroup}), nanstd(acc_all{iGroup}) / sqrt(sum(~isnan(acc_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(acc_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(colors, 1), [regions(1:3), 'Shuffle'], '', 'Decoding accuracy')
xlim([0.5, size(colors, 1) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)