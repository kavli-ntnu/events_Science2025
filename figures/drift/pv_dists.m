
function pv_dists(regions)

try
    load figp
catch
    figp = [440   278   560   420];
end

for iRegion = 1:length(regions)
    dists_pool = nan(10, 10, 100);
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            smat_n = tmp.smat_n;
            epochs = tmp.epochs;

            % average distances not PVs
            score = smat_n';
            for ii = 1:max(epochs)
                for jj = 1:max(epochs)
                    if ii < jj
                        tmp1 = squeeze(score(epochs == ii, :));
                        tmp2 = squeeze(score(epochs == jj, :));
                        stop_ind = size(tmp1, 1);
                        dists_allD = squareform(pdist(vertcat(tmp1, tmp2),'cosine'));
                        dists_endpt = dists_allD(1:stop_ind, stop_ind+1:end);
                        % fill both diagonals
                        dists_pool(ii, jj, iPool) = nanmean(dists_endpt(:));
                        dists_pool(jj, ii, iPool) = dists_pool(ii, jj, iPool);
                    end
                end
            end
        end
    end
    dists_all{iRegion} = dists_pool;
end

%% examples
colors{1} = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
colors{2} = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0.8, 1, 64)');
colors{3} = horzcat(linspace(0, 1, 64)', linspace(0.4, 1, 64)', linspace(0, 1, 64)');
session_inds = [17, 8, 3];
for iRegion = 1:length(regions)
    figure('pos', figp)
    imagesc(dists_all{iRegion}(:, :, session_inds(iRegion)))
    c = colorbar;
    COLOR = colors{iRegion};
    colormap(gca, flipud(COLOR))
    clim([0.1 0.21])
    fixPlot([1, 10], num2str([1, 10]'), 'Time (min)', 'Time (min)')
    set(gca, 'ydir', 'nor', 'ytick', [1, 10], 'fontsize', 24), axis square, box on
    c.Label.String = sprintf('Distance traveled\n(ambient space)');
    c.Label.FontSize = 24;
    title(regions{iRegion})
end

%% summary
for iRegion = 1:length(regions)
    figure('pos', figp)
    imagesc(nanmean(dists_all{iRegion}, 3))
    c = colorbar;
    COLOR = colors{iRegion};
    colormap(gca, flipud(COLOR))
    clim([0.11 0.21])
    fixPlot([1, 10], num2str([1, 10]'), 'Time (min)', 'Time (min)')
    set(gca, 'ydir', 'nor', 'ytick', [1, 10], 'fontsize', 24), axis square, box on
    c.Label.String = sprintf('Distance traveled\n(ambient space)');
    c.Label.FontSize = 24;
    title(regions{iRegion})
end