

function dists_all = distance_traveled_circshift(regions, colors)

rng('default')
for iRegion = 1:length(regions)
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            smat_n = tmp.smat_n;
            epochs = tmp.epochs;
            if size(smat_n, 1) < 60
                continue
            end
            smat_n = smat_n(:, 13:end-12);
            epochs = epochs(13:end-12);
            total_dist = calculate_pv_distance(smat_n, epochs);
            dists_all{iRegion}(iPool, 1) = total_dist;

            smat_n = tmp.smat_n;
            epochs = tmp.epochs;
            for i = 1:size(smat_n, 1)
                smat_n(i, :) = circshift(smat_n(i, :), randi([-12, 12]));
            end
            smat_n = smat_n(:, 13:end-12);
            epochs = epochs(13:end-12);
            total_dist = calculate_pv_distance(smat_n, epochs);
            dists_all{iRegion}(iPool, 2) = total_dist;

        else
            break
        end
    end
end

figure
hold on
for iRegion = 1:length(regions)
    COLOR = colors(iRegion, :);
    plot(1:2, nanmean(dists_all{iRegion}, 1), '.', 'color', COLOR, 'markersize', 30)
    errorbar(1:2, nanmean(dists_all{iRegion}, 1), nanstd(dists_all{iRegion}, [], 1) / sqrt(size(dists_all{iRegion}, 1)), 'color', COLOR, 'linew', 2)
end
fixPlot(1:2, {'Actual', 'Shifted'}, '', 'Distance traveled')
set(gca, 'fontsize', 24)
load figp
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) * 0.67;
set(gcf,'pos',figp_skinny), movegui
axis([0.5 2.5 0.11 0.2])
rotateXLabels(gca, 0)