
function uniform_peaks(regions, colors)

n_sessions = [26, 18, 12];

for iRegion = 1:length(regions)
    all_peaks = nan(n_sessions(iRegion), 60);
    all_peaks_sh = nan(n_sessions(iRegion), 60);
    n_iter = 20;
    for iPool = 1:n_sessions(iRegion)
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
        load(fname, 'smat_n')
        if size(smat_n, 2) == 60
            peaks = zeros(size(smat_n, 1), size(smat_n, 2));
            for iCell = 1:size(smat_n, 1)
                [~, mind] = max(smat_n(iCell, :));
                peaks(iCell, mind) = peaks(iCell, mind) + 1;
            end
            all_peaks(iPool, :) = sum(peaks) / size(smat_n, 1);
    
            peaks_iter = nan(n_iter, 60);
            for iIter = 1:n_iter
                tmp = smat_n(:, randperm(size(smat_n, 2), size(smat_n, 2)));
                peaks_sh = zeros(size(smat_n, 1), size(smat_n, 2));
                for iCell = 1:size(smat_n, 1)
                    [~, mind] = max(tmp(iCell, :));
                    peaks_sh(iCell, mind) = peaks_sh(iCell, mind) + 1;
                end
                peaks_iter(iIter, 1:size(tmp, 2)) = sum(peaks_sh) / size(smat_n, 1);
            end
            all_peaks_sh(iPool, 1:size(tmp, 2)) = nanmean(peaks_iter);
        end
    end

    figure, hold on
    errorbar(nanmean(all_peaks_sh), nanstd(all_peaks_sh, [], 1) / sqrt(size(all_peaks_sh, 1)), '.-', 'color', [0.5 0.5 0.5], 'linew', 2, 'markers', 30)
    errorbar(nanmean(all_peaks), nanstd(all_peaks, [], 1) / sqrt(size(all_peaks, 1)), '.-', 'color', colors(iRegion, :), 'linew', 2, 'markers', 30)
    plot([0 61], [prctile(all_peaks_sh(:), 1), prctile(all_peaks_sh(:), 1)], 'k:')
    plot([0 61], [prctile(all_peaks_sh(:), 99), prctile(all_peaks_sh(:), 99)], 'k:')
    
    load figp
    fixPlot(3.5:6:60, num2str([1:10]'), 'Time (min)', 'Fraction of cells')
    axis([0.5 60.5 0 0.15])
    set(gcf,'pos',figp), movegui
    set(gca,'fontsize', 24)
end