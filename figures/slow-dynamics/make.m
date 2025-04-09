
%%
addpath(genpath('N:\benjamka\events\figures\slow-dynamics'))
regions = {'LEC', 'MEC', 'CA1'};
colors = [0, 0, 0; 0, 0, 0.8; 0, 0.4, 0; 0.5, 0.5 0.5];
WRITE_SOURCE = 0;

%% (A) example traces
fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', 'LEC', 15);
% fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', 'MEC', 6);
% fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', 'CA1', 1);
tmp = load(fname);
smat_n = tmp.smat_n;
N = size(smat_n, 1);
smat_all = [];
clear fano_store
fano_poiss = 4.6384e-04;
sm_fac = 30;
for i = 1:N
    smat_all = [smat_all; smat_n(i, :)];
    sm_rate = general.smooth(smat_n(i, :), sm_fac / 0.5);
    fano_store(i) = log((var(sm_rate) / mean(sm_rate)) / fano_poiss);
end
smat_all_sm = general.smooth(smat_all, [0, sm_fac / 0.5]);
[~, sind] = sort(fano_store, 'descend');

dt = 0.5;
sm_fac_fast = 1;
sm_fac_slow = 30;
figure
for i = 1:4
    subplot(1, 4, i)
    plot(general.smooth(smat_all(sind(i), :), sm_fac_fast  / dt), 'color', [colors(1, :), 0.3])
    hold on
    plot(general.smooth(smat_all(sind(i), :), sm_fac_slow  / dt), 'color', colors(1, :), 'linew', 2)
    xlim([1, size(smat_all, 2) + 1])
    fixPlot([1, 601, 1201], {'0', '5', '10'}, 'Time (min)', 'Norm firing rate')
    box off
end

if WRITE_SOURCE
    lin = findall(gcf, 'type', 'line');
    data = arrayfun(@(l) [l.YData(:)], lin, 'UniformOutput', false);
    data = flipud(data);
    writematrix([vertcat(data{1}), vertcat(data{2})], 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'A_high_cell1');
    writematrix([vertcat(data{3}), vertcat(data{4})], 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'A_high_cell2');
    writematrix([vertcat(data{5}), vertcat(data{6})], 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'A_high_cell3');
    writematrix([vertcat(data{7}), vertcat(data{8})], 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'A_high_cell4');
end

figure
for i = 1:4
    subplot(1, 4, i)
    plot(general.smooth(smat_all(sind(end - i), :), sm_fac_fast  / dt), 'color', [colors(1, :), 0.3])
    hold on
    plot(general.smooth(smat_all(sind(end - i), :), sm_fac_slow  / dt), 'color', colors(1, :), 'linew', 2)
    xlim([1, size(smat_all, 2) + 1])
    fixPlot([1, 601, 1201], {'0', '5', '10'}, 'Time (min)', 'Norm firing rate')
    box off
end

if WRITE_SOURCE
    lin = findall(gcf, 'type', 'line');
    data = arrayfun(@(l) [l.YData(:)], lin, 'UniformOutput', false);
    data = flipud(data);
    writematrix([vertcat(data{1}), vertcat(data{2})], 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'A_low_cell1');
    writematrix([vertcat(data{3}), vertcat(data{4})], 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'A_low_cell2');
    writematrix([vertcat(data{5}), vertcat(data{6})], 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'A_low_cell3');
    writematrix([vertcat(data{7}), vertcat(data{8})], 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'A_low_cell4');
end

%% (B) fano factor
% examples from 'N:\spacetime\time\27285_Elm\2021-06-30_13-58-39'
load('N:\benjamka\events\data\fano_examples.mat')
figure('position', [272, 42, 314, 774])
hold on

mmin = min([fano_LEC; fano_MEC; fano_CA1]);
mmax = max([fano_LEC; fano_MEC; fano_CA1]);
edges = linspace(mmin, mmax, 20);
xvals = edges(1:end-1) + min(diff(edges)) / 2;

subplot(311)
cnts = histcounts(fano_LEC(:), edges);
bar(xvals, cnts / sum(cnts), 'facecolor', colors(1, :))
fixPlot('', [], 'Log normalized fano factor', 'Proportion')
axis([mmin, mmax, 0, 0.2])
subplot(312)
cnts = histcounts(fano_MEC(:), edges);
bar(xvals, cnts / sum(cnts), 'facecolor', colors(2, :))
fixPlot('', [], 'Log normalized fano factor', 'Proportion')
axis([mmin, mmax, 0, 0.2])
subplot(313)
cnts = histcounts(fano_CA1(:), edges);
bar(xvals, cnts / sum(cnts), 'facecolor', colors(3, :))
fixPlot('', [], 'Log normalized fano factor', 'Proportion')
axis([mmin, mmax, 0, 0.2])

if WRITE_SOURCE
    bars = findall(gcf, 'type', 'bar');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], bars, 'UniformOutput', false);
    data = flipud(data);
    writematrix(vertcat(data{1}), 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'B_example_LEC');
    writematrix(vertcat(data{2}), 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'B_example_MEC');
    writematrix(vertcat(data{3}), 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'B_example_CA1');
end

fano_all = fano_factor(regions, colors);

if WRITE_SOURCE
    values = arrayfun(@(x) {x}, cell2mat(fano_all(:)));
    labels = [repmat({'LEC'}, length(fano_all{1}), 1); repmat({'MEC'}, length(fano_all{2}), 1); repmat({'CA1'}, length(fano_all{3}), 1)];
    data = [values, labels];
    writecell(data, 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'B_summary');
end

%% (C) necessity
dist_sub_wn = fano_subsample_within(regions, colors);

if WRITE_SOURCE
    writematrix(dist_sub_wn{1}, 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'C_LEC');
    writematrix(dist_sub_wn{2}, 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'C_MEC');
    writematrix(dist_sub_wn{3}, 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'C_CA1');
end

p = anova_rm_boot_mainEffect(dist_sub_wn)

%% (D) sufficiency
dist_sub_bn = fano_subsample_between(regions, colors);

if WRITE_SOURCE
    writematrix(dist_sub_bn{1}, 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'D_LEC');
    writematrix(dist_sub_bn{2}, 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'D_MEC');
    writematrix(dist_sub_bn{3}, 'N:\benjamka\events\figures\source_data_Fig5.xlsx', 'Sheet', 'D_CA1');
end

p = anovan_boot_mainEffect(dist_sub_bn)
