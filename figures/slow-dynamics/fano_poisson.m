
function fano_poisson

%% Poisson fano

% set up the experiment
exp_params.Fs = 0.001; % 1 msec
exp_params.length = 60 * 20; % 10 min

% characterize the neuron
nrn_params.norm_mean_rate = 1;
nrn_params.bin_width = 0.5; % sec
nrn_params.sm_fac = 30; % sec
sample_times = 0:exp_params.Fs:exp_params.length;

clear smat_n_poiss firing_rate_all sm_rate_all fano_poiss
rng('default')
for i = 1:500
    % determine when neuron spikes
    rand_vals = rand(size(sample_times));
    spike_times = find((nrn_params.norm_mean_rate * exp_params.Fs) > rand_vals) * exp_params.Fs;

    % create binned firing rate
    bin_edges = min(sample_times):nrn_params.bin_width:max(sample_times);

    spike_counts = histcounts(spike_times, bin_edges);
    spike_counts_n = spike_counts / ((nanmax(spike_counts) - nanmin(spike_counts)) + 5); % soft norm
    sm_rate = general.smooth(spike_counts_n, nrn_params.sm_fac / nrn_params.bin_width);
    fano_poiss(i) = var(sm_rate) / mean(sm_rate);
end

mean(fano_poiss)
