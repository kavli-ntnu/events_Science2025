
addpath(genpath('N:\benjamka\events\figures\event-boundaries'))
regions = {'LEC', 'MEC', 'CA1'};
colors = [0, 0, 0; 0, 0, 0.8; 0, 0.4, 0; 0.5, 0.5, 0.5]; % last is shuffle
WRITE_SOURCE = 0;

%% (B)
for iRegion = 1
    [speed_of] = trajectory_speed_of(regions(iRegion), colors(iRegion, :));
    title(sprintf('%s', regions{iRegion}), 'color', colors(iRegion, :))
end

if WRITE_SOURCE
    writematrix(speed_of, 'N:\benjamka\events\figures\source_data_Fig3.xlsx', 'Sheet', 'B');
end

n = size(speed_of, 1);
if lillietest(speed_of(:, 1))
    [pval, ~, stats] = signrank(speed_of(:, 1));
    fprintf('W = %0.2f, p = %0.2f, Wilcoxon signed-rank test, n = %d sessions\n', stats.signedrank, pval, n);
else
    [~, pval, ~, stats] = ttest(speed_of(:, 1));
    fprintf('t(%d) = %.2f, p = %.3f, one-sample t-test, n = %d sessions\n', n - 1, stats.tstat, pval, n);
end

%% (C)
speed_f8 = trajectory_speed_f8();

if WRITE_SOURCE
    writematrix(speed_f8, 'N:\benjamka\events\figures\source_data_Fig3.xlsx', 'Sheet', 'C');
end

n = size(speed_f8, 1);
if lillietest(speed_f8(:, 2))
    [pval, ~, stats] = signrank(speed_f8(:, 2));
    fprintf('W = %0.2f, p = %0.2f, Wilcoxon signed-rank test, n = %d sessions\n', stats.signedrank, pval, n);
else
    [~, pval, ~, stats] = ttest(speed_f8(:, 2));
    fprintf('t(%d) = %.2f, p = %.3f, one-sample t-test, n = %d sessions\n', n - 1, stats.tstat, pval, n);
end

%% (D)
speed_seq = trajectory_speed_seq();

if WRITE_SOURCE
    writematrix(speed_of, 'N:\benjamka\events\figures\source_data_Fig3.xlsx', 'Sheet', 'D');
end

n = size(speed_seq, 1);
[~, pval, ~, stats] = ttest(speed_seq(:, 1));
fprintf('t(%d) = %.2f, p = %.3f, one-sample t-test, n = %d sessions\n', n - 1, stats.tstat, pval, n);
[~, pval, ~, stats] = ttest(speed_seq(:, 10));
fprintf('t(%d) = %.2f, p = %.3f, one-sample t-test, n = %d sessions\n', n - 1, stats.tstat, pval, n);

%% (E) first near time causes jump larger than other near times

% example_trajectory_obj()
[speed_first] = trajectory_speed_obj_contact();

if WRITE_SOURCE
    writematrix(speed_first, 'N:\benjamka\events\figures\source_data_Fig3.xlsx', 'Sheet', 'E');
end

n = size(speed_first, 1);
if lillietest(speed_first(:, 3))
    [pval, ~, stats] = signrank(speed_first(:, 3));
    fprintf('W = %0.2f, p = %0.2f, Wilcoxon signed-rank test, n = %d first contacts\n', stats.signedrank, pval, n);
else
    [~, pval, ~, stats] = ttest(speed_first(:, 3));
    fprintf('t(%d) = %.2f, p = %.3f, one-sample t-test, n = %d first contacts\n', n - 1, stats.tstat, pval, n);
end