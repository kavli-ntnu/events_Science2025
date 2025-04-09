
function [sig_per_all, mean_cov_all] = time_constant(regions, colors)

numSessions = [26, 18, 12];
fano_poiss = 4.6384e-04;
sm_fac = 30;
dt = 0.5;
sm_fac_fast = 1;
sm_fac_slow = 30;

%% get time constant from traces for all significant temporally modulated cells from GLM
for iRegion = 1:length(regions)

    decay = nan(1, 10e6);
    cnt = 0;
    clear sig_per N_per mean_cov fano_store arg_max
    for iSession = 1:numSessions(iRegion)
        fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', regions{iRegion}, iSession);
        load(fname)

        % use GLM cells
        sig_inds = p(:,3) < 0.05;
        b = b(sig_inds, 3);
        % smat_all = smat_n;
        smat_n = smat_n(sig_inds, :);

        % use fano cells
        % smat_all = [];
        % fano_store = [];
        % for iCell = 1:size(smat_n, 1)
        %     smat_all = [smat_all; smat_n(iCell, :)];
        %     sm_rate = general.smooth(smat_n(iCell, :), sm_fac / dt);
        %     fano_store(iCell) = log((var(sm_rate) / mean(sm_rate)) / fano_poiss);
        % end
        % sig_inds = fano_store > 2;
        % % fano_store = fano_store(sig_inds);
        % % [~, sind] = sort(fano_store, 'descend');
        % smat_n = smat_n(sig_inds, :);
        % for iCell = 1:size(smat_n, 1)
        %     [~, arg_max(iCell)] = max(general.smooth(smat_n(iCell, :), sm_fac / dt));
        % end
        % [~, sind] = sort(arg_max, 'ascend');

        % covariance
        tmp = cov(smat_n');
        tmp(find(eye(size(tmp)))) = nan;
        mean_cov(iSession) = nanmean(abs(tmp(:)));

        sig_per(iSession) = sum(sig_inds) / size(p, 1);
        N_per(iSession) = size(p, 1);

        % time constant
        decay_exp = [];
        for i = 1:size(smat_n, 1)
            cnt = cnt + 1;
            [f, gof] = fit([1:size(smat_n, 2)]', smat_n(i, :)','exp1');
            decay(cnt) = (1 / (f.b * .5)) / 60;
            decay_exp = [decay_exp, (1 / (f.b * .5)) / 60];
        end

        % example covariance structure for ramping cells
        if (iRegion == 1 && iSession == 15) || (iRegion == 2 && iSession == 6) || (iRegion == 3 && iSession == 1)
            [~, sind] = sort(decay_exp, 'ascend');
            smat_n = smat_n(sind, :);
            tmp = cov(smat_n');
            tmp(find(eye(size(tmp)))) = nan;
            figure, imagesc(tmp)
            title(sprintf(regions{iRegion}))
            clim([-0.01, 0.01])
        end

    end
    sig_per_all{iRegion} = sig_per;
    mean_cov_all{iRegion} = mean_cov;

    [cnts, edges] = histcounts(decay, -200:10:200);
    figure
    bar(edges(1:end-1), cnts ./ sum(N_per), 'facecolor', colors(iRegion, :))
    load figp
    fixPlot(-150:150:150, [], 'Decay time (min)', 'Fraction of cells')
    axis([-200, 200, 0, 0.025])
    set(gcf,'pos',figp), movegui
    set(gca,'fontsize', 24)
    rotateXLabels(gca, 0)

end

figure, hold on
for iGroup = 1:size(regions, 2)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(sig_per_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(sig_per_all{iGroup}), nanstd(sig_per_all{iGroup}) / sqrt(sum(~isnan(sig_per_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(sig_per_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(regions, 2), regions, '', 'Fraction of cells')
xlim([0.5, size(regions, 2) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

figure, hold on
for iGroup = 1:size(regions, 2)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(mean_cov_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(mean_cov_all{iGroup}), nanstd(mean_cov_all{iGroup}) / sqrt(sum(~isnan(mean_cov_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(mean_cov_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(regions, 2), regions, '', 'Mean absolute covariance')
xlim([0.5, size(regions, 2) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

return

%%
% % smat_n = smat_n(:, 1:1201);
% N = size(smat_n, 1);
% smat_all = [];
% clear fano_store
% fano_poiss = 4.6384e-04;
% sm_fac = 30;
% for i = 1:N
%     smat_all = [smat_all; smat_n(i, :)];
%     sm_rate = general.smooth(smat_n(i, :), sm_fac / 0.5);
%     fano_store(i) = log((var(sm_rate) / mean(sm_rate)) / fano_poiss);
% end
% smat_all_sm = general.smooth(smat_all, [0, sm_fac / 0.5]);
% [~, sind] = sort(fano_store, 'descend');
% 
% %%
% binSize = 1; % in seconds
% width = 600;     % in seconds
% xrange = -width:binSize:width;
% nBins = length(xrange);
% bounds = [601:660];
% 
% figure
% for i = 1:4
%     subplot(1, 4, i)
%     cellInd = sind(i);
%     [ACD,xrange] = MClustStats.CrossCorr(sCell{cellInd},sCell{cellInd},binSize,nBins);
%     xrange = xrange(bounds);
%     ACD = ACD(bounds);
%     bar(xrange,ACD,'FaceColor','k','EdgeColor','k');
%     set(gca,'XLim',[0 60]);
%     fixPlot([0, 60], {'0', '1'}, 'Lag (min)', 'Spike counts')
%     box off
% end
% 
%% fit to autocorr
exp_fit = nan(1, N);
for i = 1:N
    % cellInd = sind(i);
    cellInd = i;
    [ACD,xrange] = MClustStats.CrossCorr(sCell{cellInd},sCell{cellInd},binSize,nBins);
    xrange = xrange(bounds);
    ACD = ACD(bounds);
    [f, gof] = fit(xrange,ACD,'exp1');
    exp_fit(i) = f.b;
    exp_r2(i) = gof.rsquare;
end

% fit_transformed = log(exp_fit * -1);
% [~, sind_exp] = sort(fit_transformed, 'descend');
[~, sind_exp] = sort(abs(exp_fit), 'descend');

%% fit exponential to initial decay of autocorr

fs = 1 / dt;
tau = nan(1, size(smat_n, 1));
% rsquare = nan(1, size(smat_n, 1));
% figure
for i = 1:size(smat_n, 1)

    firing_rate = smat_n(sind(i), :);

    [acf, lags] = xcorr(firing_rate - mean(firing_rate), 'unbiased');
    lags = lags / fs; 

    % Find the positive lags
    positive_lags = lags(lags >= 0)';
    acf_positive = acf(lags >= 0)';

    % Normalize ACF (optional for stability)
    acf_positive = acf_positive / max(acf_positive);

    start_idx = 1 / dt;
    cutoff_idx = 90 / dt;

    % Use only the early decaying portion for fitting
    valid_lags = positive_lags(start_idx:cutoff_idx);
    valid_acf = acf_positive(start_idx:cutoff_idx);

    % subplot(4, 8, i)
    % plot(valid_lags, valid_acf, '-', 'color', [0.5 0.5 0.5], 'linew', 1)
    % plot(general.smooth(firing_rate, 30 / dt))

    % Fit an exponential function to the decaying portion using 'exp1'
    try
        [fit_exp, gof] = fit(valid_lags, valid_acf, 'exp1');
        % hold on
        % y_fit = feval(fit_exp, valid_lags);
        % plot(valid_lags, y_fit, 'k-', 'linew', 2)
        % axis square
    catch
        continue
    end

    % Extract time constant tau from the fit
    b = fit_exp.b; % Exponential decay rate

    % Ensure tau is positive
    if b < 0
        tau(i) = -1 / b; % Time constant
        % rsquare(i) = gof.rsquare;
    end
    % title(sprintf('tau = %.3f', tau(i)))

end
edges = 0:1:120;
cnts = histcounts(tau, 0:1:120);
figure, bar(edges(1:end-1), cnts / sum(cnts), 'facecolor', colors(1, :))
