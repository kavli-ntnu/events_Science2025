

function dist_sub = fano_subsample_within_progressive(regions, colors)

sm_fac = 30;
fano_poiss = 4.6384e-04; % mean for poiss with 30 sec smoothing (4.6384e-04 with dt 0.5) (0.0044 with dt 10)
dt = 0.5;
rng('default')
n_iter = 1;

for iRegion = 1:length(regions)
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            smat_n = tmp.smat_n;
            N = size(smat_n, 1);
            fano = nan(N, 1);
            cnt = 0;
            for j = 1:N
                cnt = cnt + 1;
                sm_rate = general.smooth(smat_n(j, :), sm_fac / dt);
                fano(cnt) = log((var(sm_rate) / mean(sm_rate)) / fano_poiss);
            end
            [~, sortInd] = sort(fano, 'descend');
            fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
            tmp = load(fname);
            smat_n = tmp.smat_n;
            epochs = tmp.epochs;

            smat_n_full = smat_n;

            frac_cnt = 1;
            for iFraction = [2:2:50]
                
                % n_blocks = iFraction;
                inds1 = 1;
                % inds2 = floor(N / n_blocks);
                inds2 = floor(N * (iFraction / 100));
                if inds2 > N
                    inds2 = N;
                end
                inds = inds1:inds2;
                N_sample = N - length(inds);
        
                tmp_dists = [];
                for iIter = 1:n_iter
                    smat_n = smat_n_full(datasample(1:N, N_sample, 'replace', false), :);
                    total_dist = calculate_pv_distance(smat_n, epochs);
                    tmp_dists = [tmp_dists, total_dist];
                end
                dist_sub{iRegion}(iPool, frac_cnt, 1) = nanmean(tmp_dists);

                tmp_dists = [];
                for iIter = 1:n_iter
                    smat_n = smat_n_full(sortInd((max(inds)+1):end), :); % remove top cells
                    smat_n = smat_n(datasample(1:size(smat_n, 1), N_sample, 'replace', false), :);
                    total_dist = calculate_pv_distance(smat_n, epochs);
                    tmp_dists = [tmp_dists, total_dist];
                end
                dist_sub{iRegion}(iPool, frac_cnt, 2) = nanmean(tmp_dists);

                frac_cnt = frac_cnt + 1;
            end
        else
            break
        end
    end
end

%%
for iRegion = 1:length(regions)
    figure
    hold on
    COLOR = colors(iRegion, :);
    plot(1:25, squeeze(nanmean(dist_sub{iRegion}(:, :, 1))), '-', 'color', colors(end, :), 'linew', 1)
    plot(1:25, squeeze(nanmean(dist_sub{iRegion}(:, :, 2))), '', 'color', COLOR, 'linew', 1)
    for iComp = 1:25
        plot(iComp, nanmean(squeeze(dist_sub{iRegion}(:, iComp, 1)), 1), '.', 'color', colors(end, :), 'markersize', 30)
        errorbar(iComp, nanmean(squeeze(dist_sub{iRegion}(:, iComp, 1)), 1), nanstd(squeeze(dist_sub{iRegion}(:, iComp, 1)), [], 1) / sqrt(size(squeeze(dist_sub{iRegion}(:, iComp, 1)), 1)), 'color', colors(end, :), 'linew', 2)
        plot(iComp, nanmean(squeeze(dist_sub{iRegion}(:, iComp, 2)), 1), '.', 'color', COLOR, 'markersize', 30)
        errorbar(iComp, nanmean(squeeze(dist_sub{iRegion}(:, iComp, 2)), 1), nanstd(squeeze(dist_sub{iRegion}(:, iComp, 2)), [], 1) / sqrt(size(squeeze(dist_sub{iRegion}(:, iComp, 2)), 1)), 'color', COLOR, 'linew', 2)
    end
    fixPlot(1:4:25, num2str([2:8:50]'), 'Percent removed', sprintf('Distance traveled\nin full space'))
    set(gca, 'fontsize', 24)
    load figp
    set(gcf,'pos',figp), movegui
    axis([0.5 25.5 0.08 0.24])
    rotateXLabels(gca, 0)
    title(sprintf('%s', regions{iRegion}), 'color', COLOR)
end


