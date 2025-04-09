

function corr_all = corr_structure(regions, colors)

edges = -1:0.1:1;
xvals = edges(1:end-1) + min(diff(edges)) / 2;

sm_fac = 30;
dt = 0.5;
clear corr_pool
for iRegion = 1:length(regions)
    corr_pool = [];
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            smat_n = tmp.smat_n;
            smat_n = general.smooth(smat_n, [0, sm_fac / dt]);
            corr_mat = npx_banal.corrMat(smat_n'); % transpose to correlate across neurons, not time
            corr_mat(logical(eye(size(corr_mat)))) = nan;
            mean_corr = nanmean(corr_mat(:));
            disp(iPool)

        else
            break
        end
        corr_pool = [corr_pool; mean_corr];
    end

    % store vals
    corr_all{iRegion} = corr_pool;
end

figure, hold on
for iGroup = 1:size(colors, 1)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(corr_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(corr_all{iGroup}), nanstd(corr_all{iGroup}) / sqrt(sum(~isnan(corr_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(corr_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(colors, 1), regions, '', 'Mean pairwise correlation')
xlim([0.5, size(colors, 1) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
