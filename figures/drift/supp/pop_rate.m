
function poprate_all = pop_rate(regions, colors)

n_sessions = [26, 18, 12];
for iRegion = 1:length(regions)
    poprate = nan(n_sessions(iRegion), 100);
    for iPool = 1:n_sessions(iRegion)
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
        tmp = load(fname);
        poprate(iPool, 1:size(tmp.smat_n, 2)) = sum(tmp.smat_n) / size(tmp.smat_n, 1);
    end
    poprate_all{iRegion} = minions.removeNans(poprate, 'cols', 'all');
end

figure, hold on
for iGroup = length(regions):-1:1
    COLOR = colors(iGroup, :);
    plot(nanmean(poprate_all{iGroup}), '.', 'color', COLOR, 'linew', 2, 'markersize', 10)
    errorbar(nanmean(poprate_all{iGroup}), nanstd(poprate_all{iGroup}) ./ sqrt(sum(~isnan(poprate_all{iGroup}))), 'color', COLOR, 'linew', 2)
end

load figp
fixPlot(3.5:6:60, num2str([1:10]'), 'Time (min)', 'Normalized population firing rate')
axis([0.5 60.5 0.3 0.6])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
