

function dists_all = distance_traveled_cumulative(regions, colors)

figure, hold on
clear dists_pool
bin_strings = {'', '_1s', '_500ms', '_100ms'};
for iRegion = 1:length(regions)
    dists_pool = nan(100, 10);
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            smat_n = tmp.smat_n;
            epochs = tmp.epochs;
            score = smat_n';
            tmp_dists = [];
            for iBin = 1:max(epochs)-1
                tmp1 = squeeze(score(epochs == iBin, :));
                tmp2 = squeeze(score(epochs == iBin + 1, :));
                stop_ind = size(tmp1, 1);
                dists_allD = squareform(pdist(vertcat(tmp1, tmp2),'cosine'));
                dists_endpt = dists_allD(1:stop_ind, stop_ind+1:end);
                tmp_dists = [tmp_dists, nanmean(dists_endpt(:))];
            end
            try
                dists_pool(iPool, :) = cumsum([0, tmp_dists], 'omitnan');
            end
        else
            break
        end
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
fixPlot(1:10, [], 'Time (min)', 'Cumulative distance traveled')
xlim([0.5, 10.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)