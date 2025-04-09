
function pv_dists

try
    load figp
catch
    figp = [440   278   560   420];
end

%% figure-eight trial
figure
load('N:\benjamka\events\data\figure-eight\smat_trialTime\smat_n_cedar_12-15_11-47.mat')
epochs = repmat(1:6, 1, size(smat_n, 2) / 6);

% average distances not PVs
dists_trial = nan(max(epochs));
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
            dists_trial(ii, jj) = nanmean(dists_endpt(:));
            dists_trial(jj, ii) = dists_trial(ii, jj);
        end
    end
end
imagesc(dists_trial)
c = colorbar;
COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
colormap(gca, flipud(COLOR))
% clim([0, 0.1276])
fixPlot([1, 3, 6], num2str([1, 3, 6]'), 'Trial time (sec)', 'Trial time (sec)')
set(gca, 'ydir', 'nor', 'ytick', [1, 3, 6], 'fontsize', 24), axis square, box on
c.Label.String = sprintf('Distance traveled\nin full space');
c.Label.FontSize = 24;

%% figure-eight session
figure
load('N:\benjamka\events\data\figure-eight\pos_full_cedar_12-15_11-47.mat')
[smat, smat_n, smat_z, fr] = npx_banal.binSpikes(sCell, posT, 10);
epochLength = 6;
numEpochs = ceil(size(smat_n, 2) / epochLength);
epochs = [];
for i = 1:numEpochs
    epochs = [epochs, zeros(1, epochLength) + i];
end
epochs = epochs(1:size(smat_n, 2));

% average distances not PVs
dists_session = nan(numEpochs);
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
            dists_session(ii, jj) = nanmean(dists_endpt(:));
            dists_session(jj, ii) = dists_session(ii, jj);
        end
    end
end
imagesc(dists_session)
c = colorbar;
COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
colormap(gca, flipud(COLOR))
% clim([0, 0.1276])
fixPlot([1, 5, 10], num2str([1, 5, 10]'), 'Time (min)', 'Time (min)')
set(gca, 'ydir', 'nor', 'ytick', [1, 5, 10], 'fontsize', 24), axis square, box on
c.Label.String = sprintf('Distance traveled\nin full space');
c.Label.FontSize = 24;

%% figure-eight trials over session
load('N:\benjamka\events\data\figure-eight\smat_trialTime\smat_n_cedar_12-15_11-47.mat')
epochs = repmat(1:6, 1, size(smat_n, 2) / 6);

dists = squareform(pdist(smat_n', 'cosine'));
clear diags
for i = 1:size(dists, 1)-1
    diags(i) = mean(diag(dists, i));
end

figure('pos', figp)
plot(diags, 'k-', 'linew', 2)
xlim([0 120])
fixPlot(0:6:119, num2str([1:20]'), 'Trial number', 'Distance traveled')
set(gca, 'fontsize', 24)
rotateXLabels(gca, 0)

figure
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf,'pos',figp_skinny), movegui
plot(diags(1:12), 'k-', 'linew', 2)
fixPlot(0:6:119, num2str([1:20]'), 'Trial number', 'Distance traveled')
set(gca, 'fontsize', 24)