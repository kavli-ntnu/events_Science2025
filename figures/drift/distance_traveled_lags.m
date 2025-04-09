

function dists_all = distance_traveled_lags(regions, colors)

figure, hold on
clear dists_pool
for iRegion = 1:length(regions)
    dists_pool = [];
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            smat_n = tmp.smat_n;
            dists = squareform(pdist(smat_n', 'cosine'));
            dists(logical(eye(size(dists)))) = nan;
            dists_lag = [];
            tmp_dist = [];
            for iDiag = 1:size(dists, 1)-1
                if mod(iDiag, 6) > 0
                    tmp_dist = [tmp_dist, nanmean(diag(dists, iDiag))];
                else
                    dists_lag = [dists_lag, nanmean(tmp_dist)];
                    tmp_dist = [];
                end  
            end
        else
            break
        end
        dists_lag(end+1:9) = nan;
        dists_pool = [dists_pool; dists_lag(1:9)];
    end

    % store vals
    dists_all{iRegion} = dists_pool;
end

for iGroup = 1:size(regions, 2)
    COLOR = colors(iGroup, :);
    plot(nanmean(dists_all{iGroup}), '.', 'color', COLOR, 'linew', 5, 'markersize', 40)
    errorbar(nanmean(dists_all{iGroup}), nanstd(dists_all{iGroup}) ./ sqrt(sum(~isnan(dists_all{iGroup}))), 'color', COLOR, 'linew', 2)
end

load figp
fixPlot(1:9, num2str([1:9]'), 'Lag (min)', 'Distance traveled')
xlim([0.5, 9.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)