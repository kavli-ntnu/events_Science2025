

function [dists_REM, dists_OF] = distance_traveled

ds = dir('N:\benjamka\events\data\sleep\raw_data4ben2');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end

inds_OF = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'OF_bin-1000ms'}, 1, length(names)), 'uniformoutput', false)));
inds_REM = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'REM_bin-1000ms'}, 1, length(names)), 'uniformoutput', false)));
traj_names_OF = names(inds_OF);
traj_names_REM = names(inds_REM);

%% REM
dists_REM = nan(length(traj_names_REM), 1);
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

    % average distances not PVs
    score = smat_n';
    tmp1 = squeeze(score(epochs == min(epochs), :));
    tmp2 = squeeze(score(epochs == max(epochs), :));
    stop_ind = size(tmp1, 1);
    dists_allD = squareform(pdist(vertcat(tmp1, tmp2),'cosine'));
    dists_endpt = dists_allD(1:stop_ind, stop_ind+1:end);
    dists_REM(iSession) = nanmean(dists_endpt(:));
end

%% Foraging
dists_OF = nan(length(traj_names_OF), 1);
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
    tmp1 = squeeze(score(epochs == min(epochs), :));
    tmp2 = squeeze(score(epochs == max(epochs), :));
    stop_ind = size(tmp1, 1);
    dists_allD = squareform(pdist(vertcat(tmp1, tmp2),'cosine'));
    dists_endpt = dists_allD(1:stop_ind, stop_ind+1:end);
    dists_OF(iSession) = nanmean(dists_endpt(:));
end

%%

figure
hold on

COLOR = 'k';
plot(1, nanmean(dists_REM), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1, nanmean(dists_REM), nanstd(dists_REM) / sqrt(sum(~isnan(dists_REM))), 'color', COLOR, 'linew', 2)
plotSpread({dists_REM}, 'xvalues', 1, 'distributionColors', COLOR)

plot(2, nanmean(dists_OF), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(2, nanmean(dists_OF), nanstd(dists_OF) / sqrt(sum(~isnan(dists_OF))), 'color', COLOR, 'linew', 2)
plotSpread({dists_OF}, 'xvalues', 2, 'distributionColors', COLOR)

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:2, {'REM', 'Foraging'}, '', 'Distance traveled')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) * 0.67;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)