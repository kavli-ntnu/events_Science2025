

function dists_all = distance_traveled_size_match(regions, colors)

rng(666)
figure, hold on
clear dists_pool
n_samples = 50:10:250;
n_iter = 50;
for iRegion = 1:length(regions)
    dists_pool = nan(100, length(n_samples));
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            smat_n_full = tmp.smat_n;
            epochs = tmp.epochs;
            N = size(smat_n_full, 1);
            cnt_sample = 0;
            for n_subsample = n_samples
                if n_subsample <= N
                    endpt_iter = [];
                    for iIter = 1:n_iter
                        tmp_inds = datasample(1:N, n_subsample, 'replace', false);
                        score = smat_n_full(tmp_inds, :)';
                        tmp1 = squeeze(score(epochs == min(epochs), :));
                        tmp2 = squeeze(score(epochs == max(epochs), :));
                        stop_ind = size(tmp1, 1);
                        dists_allD = squareform(pdist(vertcat(tmp1, tmp2),'cosine'));
                        dists_endpt = dists_allD(1:stop_ind, stop_ind+1:end);
                        endpt_iter = [endpt_iter, nanmean(dists_endpt(:))]; % keep only endpoint comparisons
                    end
                    cnt_sample = cnt_sample + 1;
                    dists_pool(iPool, cnt_sample) = nanmean(endpt_iter(:));
                end
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
    plot(n_samples, nanmean(dists_all{iGroup}), '.', 'color', COLOR, 'linew', 5, 'markersize', 40)
    errorbar(n_samples, nanmean(dists_all{iGroup}), nanstd(dists_all{iGroup}) ./ sqrt(sum(~isnan(dists_all{iGroup}))), 'color', COLOR, 'linew', 2)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot('', [], 'Number of neurons', 'Distance traveled')
ylim([0.1 0.25])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)