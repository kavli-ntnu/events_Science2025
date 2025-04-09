
function [decay_store] = time_constant_autocorr(regions, colors)

%% plot the decay times for all regions
load('N:\benjamka\events\data\time_constant_acorr.mat')

figure
set(gcf,'pos', [44, 206, 1380, 481]), movegui
for iRegion = 1:3
    subplot(1, 3, iRegion)
    [cnts, edges] = histcounts(decay_store{iRegion}, 0:2:90);
    bar(edges(1:end-1), cnts ./ sum(cnts), 'facecolor', colors(iRegion, :), 'linestyle', 'none')
    % load figp
    xlim([-1 60])
    % ylim([0 0.5])
    fixPlot(0:10:90, [], 'Decay time (sec)', 'Fraction of cells')
    axis square
    set(gca,'fontsize', 12)
    rotateXLabels(gca, 0)
end

%% plot example cells
load('N:\benjamka\events\data\foraging_500ms\glm_LEC_15.mat')
dt = 0.5;
fs = 1 / dt;

N = size(smat_n, 1);
clear fano_store
fano_poiss = 4.6384e-04;
sm_fac = 30;
for i = 1:N
    sm_rate = general.smooth(smat_n(i, :), sm_fac / dt);
    fano_store(i) = log((var(sm_rate) / mean(sm_rate)) / fano_poiss);
end
[~, sind] = sort(fano_store, 'descend');

for iCell =  [1, 3]

    firing_rate = smat_n(sind(iCell), :);

    [acf, lags] = xcorr(firing_rate - mean(firing_rate), 'unbiased');
    lags = lags / fs;

    positive_lags = lags(lags >= 0)';
    acf_positive = acf(lags >= 0)';
    acf_positive = acf_positive / max(acf_positive);

    start_idx = 1 / dt;
    cutoff_idx = 90 / dt;
    valid_lags = positive_lags(start_idx:cutoff_idx);
    valid_acf = acf_positive(start_idx:cutoff_idx);

    figure
    plot(lags, acf, 'k', 'linew', 1)
    hold on
    rectangle('pos', [1, min(ylim), 89, range(ylim)])
    fixPlot('', [], 'Lag (sec)', 'Correlation')

    figure('pos', [802.5000  236.0000  263.5000  418.0000])
    hold on
    plot(valid_lags, valid_acf, 'k', 'linew', 0.5)
    fit_exp = fit(valid_lags, valid_acf, 'exp1');
    y_fit = feval(fit_exp, valid_lags);
    plot(valid_lags, y_fit, 'k', 'linew', 2)
    tau_acorr = -1 / fit_exp.b;
    title(sprintf('Decay time = %d sec', round(tau_acorr)))
    xlim([0, 90])
    fixPlot(0:30:90, [], 'Lag (sec)', 'Correlation')

    figure
    hold on
    plot(general.smooth(firing_rate, 0.5 / dt), 'k', 'linew', 0.5)
    plot(general.smooth(firing_rate, 30 / dt), 'k', 'linew', 2)
    f = fit([1:length(firing_rate)]', firing_rate','exp1');
    y_fit = feval(f, 1:length(firing_rate));
    plot(1:length(firing_rate), y_fit, 'r-', 'linew', 2)
    tau_trace = (1 / (f.b * dt)) / 60;
    title(sprintf('Decay time = %.1f min', tau_trace))
    xlim([1, length(firing_rate) + 1])
    fixPlot([1, 601, length(firing_rate) + 1], {'0', '5', '10'}, 'Time (min)', 'Norm firing rate')

end

return

%% this actually calculates the decay times

% numSessions = [26, 18, 12];
% dt = 0.5;
% fs = 1 / dt;
% 
% for iRegion = 1:length(regions)
% 
%     decay = nan(1, 10e6);
%     cnt = 0;
%     for iSession = 1:numSessions(iRegion)
%         fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', regions{iRegion}, iSession);
%         load(fname)
%         fprintf('Region %s, Session %d ... \n', regions{iRegion}, iSession)
% 
%         for iCell = 1:size(smat_n, 1)
%             cnt = cnt + 1;
%             firing_rate = smat_n(iCell, :);
% 
%             [acf, lags] = xcorr(firing_rate - mean(firing_rate), 'unbiased');
%             lags = lags / fs;
% 
%             % Find the positive lags
%             positive_lags = lags(lags >= 0)';
%             acf_positive = acf(lags >= 0)';
% 
%             % Normalize ACF (optional for stability)
%             acf_positive = acf_positive / max(acf_positive);
% 
%             % Use only the early decaying portion for fitting
%             start_idx = 1 / dt;
%             cutoff_idx = 90 / dt;
%             valid_lags = positive_lags(start_idx:cutoff_idx);
%             valid_acf = acf_positive(start_idx:cutoff_idx);
% 
%             try
%                 [fit_exp, gof] = fit(valid_lags, valid_acf, 'exp1');
%             catch
%                 continue
%             end
% 
%             % Extract time constant tau from the fit
%             b = fit_exp.b; % Exponential decay rate
% 
%             % Ensure tau is positive
%             if b < 0
%                 decay(cnt) = -1 / b; % Time constant
%                 % rsquare(cnt) = gof.rsquare;
%             end
% 
%         end
%     end
% 
%     [cnts, edges] = histcounts(decay, 0:1:120);
%     figure
%     bar(edges(1:end-1), cnts ./ cnt, 'facecolor', colors(iRegion, :))
%     load figp
%     % fixPlot(-150:150:150, [], 'Decay time (min)', 'Fraction of cells')
%     % axis([-200, 200, 0, 0.025])
%     set(gcf,'pos',figp), movegui
%     set(gca,'fontsize', 24)
%     rotateXLabels(gca, 0)
% 
%     decay_store{iRegion} = decay;
% 
% end

%% figure-eight full task

names = {'pos_full_bubinga_12-07_16-47', ...
         'pos_full_bubinga_12-08_10-38', ...
         'pos_full_bubinga_12-09_11-48', ...
         'pos_full_cedar_12-14_16-18', ...
         'pos_full_cedar_12-15_11-47'};
dt = 0.1;
fs = 1 / dt;

decay = nan(1, 10e6);
cnt = 0;
for iSession = 1:length(names)
    fname = sprintf('N:\\benjamka\\events\\data\\figure-eight\\%s.mat', names{iSession});
    load(fname)

    [~, smat_n] = npx_banal.binSpikes(sCell, posT, dt);

    for iCell = 1:size(smat_n, 1)
        cnt = cnt + 1;
        firing_rate = smat_n(iCell, :);

        [acf, lags] = xcorr(firing_rate - mean(firing_rate), 'unbiased');
        lags = lags / fs;

        % Find the positive lags
        positive_lags = lags(lags >= 0)';
        acf_positive = acf(lags >= 0)';

        % Normalize ACF (optional for stability)
        acf_positive = acf_positive / max(acf_positive);

        % Use only the early decaying portion for fitting
        start_idx = 0.25 / dt;
        cutoff_idx = 10 / dt;
        valid_lags = positive_lags(start_idx:cutoff_idx);
        valid_acf = acf_positive(start_idx:cutoff_idx);

        try
            [fit_exp, gof] = fit(valid_lags, valid_acf, 'exp1');
        catch
            continue
        end

        % Extract time constant tau from the fit
        b = fit_exp.b; % Exponential decay rate

        % Ensure tau is positive
        if b < 0
            decay(cnt) = -1 / b; % Time constant
            % rsquare(cnt) = gof.rsquare;
        end

    end
end

figure
[cnts, edges] = histcounts(decay, 0:2:90);
bar(edges(1:end-1), cnts ./ sum(cnts), 'facecolor', colors(1, :), 'linestyle', 'none')
% load figp
xlim([-1 60])
% ylim([0 0.5])
fixPlot(0:10:90, [], 'Decay time (sec)', 'Fraction of cells')
axis square
set(gca,'fontsize', 12)
rotateXLabels(gca, 0)




