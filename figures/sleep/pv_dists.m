
function [dists_REM, dists_OF] = pv_dists(region)

switch region
    case 'LEC'
        COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
    case 'MEC'
        COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0.8, 1, 64)');
    case 'CA1'
        COLOR = horzcat(linspace(0, 1, 64)', linspace(0.4, 1, 64)', linspace(0, 1, 64)');
end

try
    load figp
catch
    figp = [440   278   560   420];
end


if strcmpi(region, 'LEC')
    ds = dir('N:\benjamka\events\data\sleep\raw_data4ben2');
    clear names
    for i = 3:length(ds)
        names{i-2} = ds(i).name;
    end
    inds_OF = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'OF_bin-1000ms'}, 1, length(names)), 'uniformoutput', false)));
    inds_REM = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'REM_bin-1000ms'}, 1, length(names)), 'uniformoutput', false)));
    traj_names_OF = names(inds_OF);
    traj_names_REM = names(inds_REM);
elseif ismember(region, {'MEC', 'CA1'})
    ds = dir('N:\benjamka\events\data\sleep\raw_data4ben_CA1-MEC');
    clear names
    for i = 3:length(ds)
        names{i-2} = ds(i).name;
    end
    inds_OF = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'OF_bin-1000ms'}, 1, length(names)), 'uniformoutput', false)));
    inds_REM = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'REM_bin-1000ms'}, 1, length(names)), 'uniformoutput', false)));
    inds_region = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({sprintf('_ROI-%s_', region)}, 1, length(names)), 'uniformoutput', false)));
    traj_names_OF = names(inds_OF & inds_region);
    traj_names_REM = names(inds_REM & inds_region);
end

%% REM
dists_REM = nan(10, 10, length(traj_names_REM));
for iSession = 1:length(traj_names_REM)
    xl = readcell(fullfile(ds(1).folder, traj_names_REM{iSession}));
    smat_n = cell2mat(xl');
    
    epochLength = 6;
    numEpochs = ceil(size(smat_n, 2) / epochLength);
    epochs = [];
    for iEpoch = 1:numEpochs
        epochs = [epochs, zeros(1, epochLength) + iEpoch];
    end
    epochs = epochs(1:size(smat_n, 2));

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
                dists_REM(ii, jj, iSession) = nanmean(dists_endpt(:));
                dists_REM(jj, ii, iSession) = dists_REM(ii, jj, iSession);
            end
        end
    end
    
end

figure('pos', figp)
imagesc(nanmean(dists_REM, 3))
c = colorbar;
% COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
colormap(gca, flipud(COLOR))
% clim([0 0.4077])
fixPlot([1, 10], num2str([1, 60]'), 'Time (sec)', 'Time (sec)')
set(gca, 'ydir', 'nor', 'ytick', [1, 10], 'yticklabel', num2str([1, 60]'), 'fontsize', 24), axis square, box on
c.Label.String = sprintf('Distance traveled\n(ambient space)');
c.Label.FontSize = 24;
title('REM')

%% Foraging
dists_OF = nan(10, 10, length(traj_names_OF));
for iSession = 1:length(traj_names_OF)
    xl = readcell(fullfile(ds(1).folder, traj_names_OF{iSession}));
    smat_n = cell2mat(xl');
    
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
                dists_OF(ii, jj, iSession) = nanmean(dists_endpt(:));
                dists_OF(jj, ii, iSession) = dists_OF(ii, jj, iSession);
            end
        end
    end

    % smat_epoch_ave = epoch_ave(smat_n, epochs);
    % dists = squareform(pdist(smat_epoch_ave(:, 1:(min(max(epochs), 10)))', 'cosine'));
    % tmp = dists;
    % tmp(find(eye(size(tmp)))) = nan;
    % dists_OF(:, :, iSession) = tmp;
end

figure('pos', figp)
imagesc(nanmean(dists_OF, 3))
c = colorbar;
% COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
colormap(gca, flipud(COLOR))
% clim([0 0.4077])
fixPlot([1, 10], num2str([1, 60]'), 'Time (sec)', 'Time (sec)')
set(gca, 'ydir', 'nor', 'ytick', [1, 10], 'yticklabel', num2str([1, 60]'), 'fontsize', 24), axis square, box on
c.Label.String = sprintf('Distance traveled\n(ambient space)');
c.Label.FontSize = 24;
title('Foraging')
