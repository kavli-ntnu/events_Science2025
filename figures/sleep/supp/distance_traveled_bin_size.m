

function [dists_REM, dists_OF] = distance_traveled_bin_size(region, COLOR)

if strcmpi(region, 'LEC')
    ds = dir('N:\benjamka\events\data\sleep\raw_data4ben2');
    clear names
    for i = 3:length(ds)
        names{i-2} = ds(i).name;
    end
elseif ismember(region, {'MEC', 'CA1'})
    ds = dir('N:\benjamka\events\data\sleep\raw_data4ben_CA1-MEC_all-bin-sizes');
    clear names
    for i = 3:length(ds)
        names{i-2} = ds(i).name;
    end
end

bin_strings = {'2000ms', '1000ms', '500ms', '100ms'};
epochLengths = [3, 6, 12, 60];
dists_REM = nan(50, length(bin_strings));
dists_OF = nan(50, length(bin_strings));

for iBin = 1:length(bin_strings)
    inds_OF = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({sprintf('OF_bin-%s', bin_strings{iBin})}, 1, length(names)), 'uniformoutput', false)));
    inds_REM = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({sprintf('REM_bin-%s', bin_strings{iBin})}, 1, length(names)), 'uniformoutput', false)));
    inds_region = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({sprintf('_ROI-%s_', region)}, 1, length(names)), 'uniformoutput', false)));
    traj_names_OF = names(inds_OF & inds_region);
    traj_names_REM = names(inds_REM & inds_region);
    
    %% REM
    for iSession = 1:length(traj_names_REM)
        xl = readcell(fullfile(ds(1).folder, traj_names_REM{iSession}));
        smat_n = cell2mat(xl');
        
        epochLength = epochLengths(iBin);
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
        dists_REM(iSession, iBin) = nanmean(dists_endpt(:));
    end
    
    %% Foraging
    for iSession = 1:length(traj_names_OF)
        xl = readcell(fullfile(ds(1).folder, traj_names_OF{iSession}));
        smat_n = cell2mat(xl');
        
        epochLength = epochLengths(iBin);
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
        dists_OF(iSession, iBin) = nanmean(dists_endpt(:));
    end
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
fixPlot(1:4, {'2 s', '1 s', '500 ms', '100 ms'}, 'Bin size', 'Distance traveled')
xlim([0.5, 4.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)