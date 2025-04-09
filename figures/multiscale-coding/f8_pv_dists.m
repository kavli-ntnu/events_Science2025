
function f8_pv_dists(regions)

try
    load figp
catch
    figp = [440   278   560   420];
end

ds = dir('N:\benjamka\events\data\figure-eight\smat_trialTime');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_smat = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
names = names(inds_smat);

dists_pool = nan(6, 6, length(names));
for iPool = 1:length(names)
    tmp = load(fullfile(ds(1).folder, names{iPool}));
    smat_n = tmp.smat_n;
    epochLength = 6;
    numEpochs = ceil(size(smat_n, 2) / epochLength);
    epochs = [];
    for iEpoch = 1:numEpochs
        epochs = [epochs, zeros(1, epochLength) + iEpoch];
    end
    epochs = epochs(1:size(smat_n, 2));

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

%% examples
colors{1} = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
colors{2} = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0.8, 1, 64)');
colors{3} = horzcat(linspace(0, 1, 64)', linspace(0.4, 1, 64)', linspace(0, 1, 64)');
limits = [0.154, 0.205; ...
          0.123, 0.147; ...
          0.114, 0.154];
session_inds = [17, 8, 3];
for iRegion = 1:length(regions)
    figure('pos', figp)
    imagesc(dists_all{iRegion}(:, :, session_inds(iRegion)))
    c = colorbar;
    COLOR = colors{iRegion};
    colormap(gca, flipud(COLOR))
    % clim(limits(iRegion, :))
    clim([0.1 0.21])
    fixPlot([1, 10], num2str([1, 10]'), 'Time (min)', 'Time (min)')
    set(gca, 'ydir', 'nor', 'ytick', [1, 10], 'fontsize', 24), axis square, box on
    c.Label.String = sprintf('Distance traveled\n(ambient space)');
    c.Label.FontSize = 24;
    title(regions{iRegion})
end

%% summary
limits = [0.154, 0.205; ...
          0.123, 0.147; ...
          0.114, 0.154];
for iRegion = 1:length(regions)
    figure('pos', figp)
    imagesc(nanmean(dists_all{iRegion}, 3))
    c = colorbar;
    COLOR = colors{iRegion};
    colormap(gca, flipud(COLOR))
    clim(limits(iRegion, :))
    fixPlot([1, 10], num2str([1, 10]'), 'Time (min)', 'Time (min)')
    set(gca, 'ydir', 'nor', 'ytick', [1, 10], 'fontsize', 24), axis square, box on
    c.Label.String = sprintf('Distance traveled\n(ambient space)');
    c.Label.FontSize = 24;
    title(regions{iRegion})
end