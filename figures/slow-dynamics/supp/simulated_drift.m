
function [dists_all, sm_rate_slow, sm_rate_fast] = simulated_drift

rng('default')
N = 400;
T = 60;
n_iter = 25;

% set up the experiment
exp_params.Fs = 0.001; % 1 msec
exp_params.length = T * 10; % 10 min

% characterize the neuron
nrn_params.norm_mean_rate = 1; % Hz
nrn_params.bin_width = 0.5; % sec
nrn_params.sm_fac_slow = 30; % sec
nrn_params.sm_fac_fast = 1; % sec
sample_times = 0:exp_params.Fs:exp_params.length;

dists_all = nan(n_iter, 2);
for iIter = 1:n_iter
    sm_rate_slow = nan(N, 60);
    sm_rate_fast = nan(N, 60);
    for iNeuron = 1:N

        % generate Poisson spikes
        rand_vals = rand(size(sample_times));
        spike_times = find((nrn_params.norm_mean_rate * exp_params.Fs) > rand_vals) * exp_params.Fs;
        bin_edges_spikes = min(sample_times):nrn_params.bin_width:max(sample_times);
        spike_counts = histcounts(spike_times, bin_edges_spikes);

        % slow vs fast dynamics separately
        tmp_slow = general.smooth(spike_counts, nrn_params.sm_fac_slow / nrn_params.bin_width);
        tmp_fast = general.smooth(spike_counts, nrn_params.sm_fac_fast / nrn_params.bin_width);
      
        % downsample to match 10 sec bins in real data
        tmp_slow = tmp_slow(1:(10/0.5):end);
        tmp_fast = tmp_fast(1:(10/0.5):end);

        % rescale rates so that slow vs fast has same range
        sm_rate_slow(iNeuron, :) = minions.rescaleData(tmp_slow)';
        sm_rate_fast(iNeuron, :) = minions.rescaleData(tmp_fast)';

    end
    
    % analyze drift for each
    smat_n = sm_rate_slow;
    epochLength = 6; % 1 min epochs
    numEpochs = ceil(size(smat_n, 2) / epochLength);
    epochs = [];
    for i = 1:numEpochs
        epochs = [epochs, zeros(1, epochLength) + i];
    end
    epochs = epochs(1:size(smat_n, 2));
    total_dist = calculate_pv_distance(smat_n, epochs);
    dists_all(iIter, 1) = total_dist;

    smat_n = sm_rate_fast;
    total_dist = calculate_pv_distance(smat_n, epochs);
    dists_all(iIter, 2) = total_dist;
end

figure, hold on

COLOR = 'k';
plot(1:2, dists_all, '-', 'color', COLOR, 'linew', 1)
plot(1:2, nanmean(dists_all, 1) , 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1:2, nanmean(dists_all, 1), nanstd(dists_all, [], 1), 'color', COLOR, 'linew', 2)

load figp
fixPlot(1:2, {'Slow', 'Fast'}, '', 'Distance traveled')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

%%

figure('pos', [395   498   870   227])
subplot(131)
plot(sm_rate_slow(1,:), 'k', 'linew', 1)
fixPlot([1, 30, 60], {'0', '5', '10'}, 'Time (min)', 'Norm rate')
subplot(132)
plot(sm_rate_slow(2,:), 'k', 'linew', 1)
fixPlot([1, 30, 60], {'0', '5', '10'}, 'Time (min)', 'Norm rate')
subplot(133)
plot(sm_rate_slow(3,:), 'k', 'linew', 1)
fixPlot([1, 30, 60], {'0', '5', '10'}, 'Time (min)', 'Norm rate')

figure('pos', [395   498   870   227])
subplot(131)
plot(sm_rate_fast(1,:), 'k', 'linew', 1)
fixPlot([1, 30, 60], {'0', '5', '10'}, 'Time (min)', 'Norm rate')
subplot(132)
plot(sm_rate_fast(2,:), 'k', 'linew', 1)
fixPlot([1, 30, 60], {'0', '5', '10'}, 'Time (min)', 'Norm rate')
subplot(133)
plot(sm_rate_fast(3,:), 'k', 'linew', 1)
fixPlot([1, 30, 60], {'0', '5', '10'}, 'Time (min)', 'Norm rate')
