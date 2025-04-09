
addpath('N:\benjamka\events\figures')
addpath(genpath('N:\benjamka\events\figures\multiscale-coding'))
regions = {'LEC', 'MEC', 'CA1'};
colors = [0, 0, 0; 0, 0, 0.8; 0, 0.4, 0; 0.5, 0.5, 0.5]; % last is shuffle
WRITE_SOURCE = 0;

%% (B) example trial trajectories
load('N:\benjamka\events\figures\multiscale-coding\f8_trial_trajectory_example.mat'); % 'cedar_12-15_11-47'
score = score(31:66, 1:2);
[vx, vy] = meshgrid(1:6, 6:11);
labels = vx(:) + 5;
data = [score, labels];

if WRITE_SOURCE
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'B');
end

%% (C) trial alignment
[dists_pool_match, dists_pool_mismatch] = trial_stability();

if WRITE_SOURCE
    writematrix([dists_pool_match', dists_pool_mismatch'], 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'C');
end

%% (D) trial decoding
[decodeError, decodeError_sh] = f8_trial_decoding();

if WRITE_SOURCE
    writematrix([decodeError', decodeError_sh'], 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'D');
end

%% (E) trial time
load('N:\benjamka\events\figures\multiscale-coding\f8_trial_trajectory_example.mat'); % 'cedar_12-15_11-47'
plot_trajectory_session(score, epochs, axLims)
cbar = findall(gcf, 'type', 'colorbar');
cbar.Label.String = 'Trial time (sec)';
set(gca, 'xtick', -5:5:5, 'ytick', -5:5:5)
xlim([-6, 8])

if WRITE_SOURCE
    scat = findall(gca, 'type', 'scatter');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], scat, 'UniformOutput', false);
    data_epochs = vertcat(data{1});
    data_bins = vertcat(data{2});
    data_bins = [repmat([1:6]', length(data_bins) / 6, 1), data_bins];
    writematrix(data_bins, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'E_bins');
    writematrix(data_epochs, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'E_epochs');
end

%% (F) session time
load('N:\benjamka\events\figures\multiscale-coding\f8_session_trajectory_example.mat'); % 'cedar_12-15_11-47'
plot_trajectory_session(score, epochs, axLims)

if WRITE_SOURCE
    scat = findall(gca, 'type', 'scatter');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], scat, 'UniformOutput', false);
    data_epochs = vertcat(data{1});
    data_bins = vertcat(data{2});
    writematrix(data_bins, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'F_bins');
    writematrix(data_epochs, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'F_epochs');
end

%% (G) angular offset
[session_wn, trial_wn, session_trial_bn] = angular_offset();

if WRITE_SOURCE
    writematrix([session_trial_bn', trial_wn', session_wn'], 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'G');
end

%% (H) pca
load('N:\benjamka\events\figures\multiscale-coding\f8_pca_example.mat');

plot_trajectory_session(score(:, 2:3), epochs_trial, 40);
if WRITE_SOURCE
    scat = findall(gca, 'type', 'scatter');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], scat, 'UniformOutput', false);
    data_epochs = vertcat(data{1});
    data_bins = vertcat(data{2});
    data_bins = [repmat([1:6]', length(data_bins) / 6, 1), data_bins];
    writematrix(data_bins, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'H_trial_bins');
    writematrix(data_epochs, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'H_trial_epochs');
end

plot_trajectory_session(score(:, 2:3), epochs_session, 40);
if WRITE_SOURCE
    scat = findall(gca, 'type', 'scatter');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], scat, 'UniformOutput', false);
    data_epochs = vertcat(data{1});
    data_bins = vertcat(data{2});
    writematrix(data_bins, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'H_session_bins');
    writematrix(data_epochs, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'H_session_epochs');
end

%% (J) seq type
load('N:\benjamka\events\figures\multiscale-coding\seq_type_trajectory_example.mat');
score(:, 3) = score(:, 3) * -1;
[xx, yy, zz] = plot_trajectory_session_3D(score, epochs, 5);
cbar = findall(gcf, 'type', 'colorbar');
cbar.Label.String = 'Trial number';
view(-55, 20)

if WRITE_SOURCE
    writematrix([xx, yy, zz], 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'J');
end

%% (K) seq type
[dists_pool, lags] = seq_odor_dists;

if WRITE_SOURCE
    tmp = dists_pool(:, :, 4);
    tmp(find(eye(size(tmp)))) = nan;
    writematrix(tmp, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'K_example');
    tmp = nanmean(dists_pool, 3);
    tmp(find(eye(size(tmp)))) = nan;
    writematrix(tmp, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'K_average');
    writematrix(lags, 'N:\benjamka\events\figures\source_data_Fig4.xlsx', 'Sheet', 'L');
end

%% (X) seq alignment 
% [dists_pool_match, dists_pool_mismatch] = stability_seq('mill');
% [~, pval, ~, stats] = ttest(dists_pool_match, dists_pool_mismatch)
