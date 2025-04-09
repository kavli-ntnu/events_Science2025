
function [dists_pool, lags] = seq_odor_dists

try
    load figp
catch
    figp = [440   278   560   420];
end

ds = dir('N:\benjamka\events\data\sequence\');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_smat = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n_type'}, 1, length(names)), 'uniformoutput', false)));
inds_MEC = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'MEC'}, 1, length(names)), 'uniformoutput', false)));
inds_CA1 = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'CA1'}, 1, length(names)), 'uniformoutput', false)));
inds_mill_only = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'mill-only'}, 1, length(names)), 'uniformoutput', false)));
names = names(inds_smat & ~inds_MEC & ~inds_CA1 & ~inds_mill_only);

dists_pool = nan(15, 15, length(names));
for iPool = 1:length(names)
    tmp = load(fullfile(ds(1).folder, names{iPool}));
    smat_n = tmp.smat_n;
    epochs = tmp.epochs;
    inds_run_ends = find(diff(epochs) < 0);
    epochs((inds_run_ends(1) + 1):end) = epochs((inds_run_ends(1) + 1):end) + 5;
    epochs((inds_run_ends(2) + 1):end) = epochs((inds_run_ends(2) + 1):end) + 5;

    % average distances not PVs
    score = smat_n';
    for ii = 1:max(epochs)
        for jj = 1:max(epochs)
            if ii <= jj
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

lags = nan(size(dists_pool, 3), size(dists_pool, 1));
for ii = 1:size(dists_pool, 3)
    for jj = 1:size(dists_pool, 1)
        lags(ii, jj) = mean(diag(dists_pool(:,:, ii), jj - 1));
    end
end
lags = lags(:, 2:end) - lags(:, 1); % normalize to amount of drift in each session

%% example session
figure('pos', figp)
tmp = dists_pool(:, :, 4);
tmp(find(eye(size(tmp)))) = nan;
imagesc(tmp)
c = colorbar;
COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
% COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0.8, 1, 64)');
% COLOR = horzcat(linspace(0, 1, 64)', linspace(0.4, 1, 64)', linspace(0, 1, 64)');
colormap(gca, flipud(COLOR))
clim([0.14 0.26])
fixPlot([1:5:15], num2str([1:5:15]'), 'Trial number', 'Trial number')
set(gca, 'ydir', 'nor', 'ytick', [1:5:15], 'yticklabel', num2str([1:5:15]'), 'fontsize', 24), axis square, box on
c.Label.String = sprintf('Distance traveled\n(ambient space)');
c.Label.FontSize = 24;
c.Ticks = [c.Ticks(1), c.Ticks(end)];

%% session average
figure('pos', figp)
tmp = nanmean(dists_pool, 3);
tmp(find(eye(size(tmp)))) = nan;
imagesc(tmp)
c = colorbar;
colormap(gca, flipud(COLOR))
clim([0.19 0.26])
fixPlot([1:5:15], num2str([1:5:15]'), 'Trial number', 'Trial number')
set(gca, 'ydir', 'nor', 'ytick', [1:5:15], 'yticklabel', num2str([1:5:15]'), 'fontsize', 24), axis square, box on
c.Label.String = sprintf('Distance traveled\n(ambient space)');
c.Label.FontSize = 24;
c.Ticks = [c.Ticks(1), c.Ticks(end)];

%% lags
figure
set(gcf, 'pos', figp), movegui
COLOR = 'k';
% COLOR = [0 0 0.8];
% COLOR = [0 0.4 0];
errorbar(nanmean(lags), nanstd(lags) ./ sqrt(sum(~isnan(lags))), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
fixPlot([1:14], num2str([1:14]'), 'Lag (num trials)', sprintf('Distance traveled\n(ambient space)'))
xlim([0.5 14.5])
set(gca, 'fontsize', 24)
rotateXLabels(gca, 0)

%% outliers
x_values = 1:14; % x-coordinates
y_values = nanmean(lags); % y-coordinates
degree = 2;
n_std = 1;
p = polyfit(x_values, y_values, degree); % Fit polynomial
y_fit = polyval(p, x_values);
residuals = abs(y_values - y_fit);
threshold = mean(residuals) + n_std*std(residuals); % Outlier threshold
point_index = x_values;
residuals(point_index) > threshold
