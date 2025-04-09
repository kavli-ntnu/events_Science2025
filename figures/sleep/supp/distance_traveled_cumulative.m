

function [dists_REM, dists_OF] = distance_traveled_cumulative(region, COLOR)


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
dists_REM = nan(length(traj_names_REM), 10);
for iSession = 1:length(traj_names_REM)
    xl = readcell(fullfile(ds(1).folder, traj_names_REM{iSession}));
    smat_n = cell2mat(xl');
    score = smat_n';

    epochLength = 6;
    numEpochs = ceil(size(smat_n, 2) / epochLength);
    epochs = [];
    for iEpoch = 1:numEpochs
        epochs = [epochs, zeros(1, epochLength) + iEpoch];
    end
    epochs = epochs(1:size(smat_n, 2));

    tmp_dists = [];
    for iBin = 1:max(epochs)-1
        tmp1 = squeeze(score(epochs == iBin, :));
        tmp2 = squeeze(score(epochs == iBin + 1, :));
        stop_ind = size(tmp1, 1);
        dists_allD = squareform(pdist(vertcat(tmp1, tmp2),'cosine'));
        dists_endpt = dists_allD(1:stop_ind, stop_ind+1:end);
        tmp_dists = [tmp_dists, nanmean(dists_endpt(:))];
    end
    dists_REM(iSession, :) = cumsum([0, tmp_dists], 'omitnan');
end

%% Foraging
dists_OF = nan(length(traj_names_OF), 10);
for iSession = 1:length(traj_names_OF)
    xl = readcell(fullfile(ds(1).folder, traj_names_OF{iSession}));
    smat_n = cell2mat(xl');
    score = smat_n';

    epochLength = 6;
    numEpochs = ceil(size(smat_n, 2) / epochLength);
    epochs = [];
    for iEpoch = 1:numEpochs
        epochs = [epochs, zeros(1, epochLength) + iEpoch];
    end
    epochs = epochs(1:size(smat_n, 2));

    tmp_dists = [];
    for iBin = 1:max(epochs)-1
        tmp1 = squeeze(score(epochs == iBin, :));
        tmp2 = squeeze(score(epochs == iBin + 1, :));
        stop_ind = size(tmp1, 1);
        dists_allD = squareform(pdist(vertcat(tmp1, tmp2),'cosine'));
        dists_endpt = dists_allD(1:stop_ind, stop_ind+1:end);
        tmp_dists = [tmp_dists, nanmean(dists_endpt(:))];
    end
    dists_OF(iSession, :) = cumsum([0, tmp_dists], 'omitnan');
end

%%
figure
hold on

% COLOR = 'k';
plot(nanmean(dists_REM), '.', 'color', COLOR, 'linew', 5, 'markersize', 40)
errorbar(nanmean(dists_REM), nanstd(dists_REM) ./ sqrt(sum(~isnan(dists_REM))), 'color', COLOR, 'linew', 2)
plot(nanmean(dists_OF), '.', 'color', COLOR, 'linew', 5, 'markersize', 40)
errorbar(nanmean(dists_OF), nanstd(dists_OF) ./ sqrt(sum(~isnan(dists_OF))), 'color', COLOR, 'linew', 2)

load figp
fixPlot(1:10, num2str([0:6:60]'), 'Time (sec)', 'Cumulative distance traveled')
axis([0.5, 10.5, 0, 4.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)
