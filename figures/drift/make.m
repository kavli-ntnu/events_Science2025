
addpath('N:\benjamka\events\figures')
addpath(genpath('N:\benjamka\events\figures\drift'))
regions = {'LEC', 'MEC', 'CA1'};
colors = [0, 0, 0; 0, 0, 0.8; 0, 0.4, 0; 0.5, 0.5, 0.5]; % last is shuffle/neighbor
WRITE_SOURCE = 0;

%% (B)
load('N:\benjamka\events\data\foraging\trajectory_examples.mat');
plot_trajectory_session(LEC.score, LEC.epochs, LEC.axLims)

if WRITE_SOURCE
    scat = findall(gca, 'type', 'scatter');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], scat, 'UniformOutput', false);
    data_epochs = vertcat(data{1});
    data_bins = vertcat(data{2});
    writematrix(data_bins, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'B_LEC_bins');
    writematrix(data_epochs, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'B_LEC_epochs');
end

plot_trajectory_session(MEC.score, MEC.epochs, MEC.axLims)

if WRITE_SOURCE
    scat = findall(gca, 'type', 'scatter');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], scat, 'UniformOutput', false);
    data_epochs = vertcat(data{1});
    data_bins = vertcat(data{2});
    writematrix(data_bins, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'B_MEC_bins');
    writematrix(data_epochs, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'B_MEC_epochs');
end

plot_trajectory_session(CA1.score, CA1.epochs, CA1.axLims)

if WRITE_SOURCE
    scat = findall(gca, 'type', 'scatter');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], scat, 'UniformOutput', false);
    data_epochs = vertcat(data{1});
    data_bins = vertcat(data{2});
    writematrix(data_bins, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'B_CA1_bins');
    writematrix(data_epochs, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'B_CA1_epochs');
end

% plot_trajectory_all(regions(1))

%% (C)
if WRITE_SOURCE
    close all
end
pv_dists(regions)

if WRITE_SOURCE
    figure(1)
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'C_LEC_example');
    figure(2)
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'C_MEC_example');
    figure(3)
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'C_CA1_example');
    figure(4)
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'C_LEC_average');
    figure(5)
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'C_MEC_average');
    figure(6)
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'C_CA1_average');
end

%% (D)
dists_all = distance_traveled(regions, colors);

if WRITE_SOURCE
    values = arrayfun(@(x) {x}, cell2mat(dists_all(:)'))';
    labels = [repmat({'LEC'}, length(dists_all{1}), 1); repmat({'MEC'}, length(dists_all{2}), 1); repmat({'CA1'}, length(dists_all{3}), 1); repmat({'Neighbor'}, length(dists_all{4}), 1)];
    data = [values, labels];
    writecell(data, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'D');
end

combos = [1, 2; 1, 3; 2, 3; 1, 4; 2, 4; 3, 4];
clear p
for i = 1:size(combos, 1)
    [~, p(i)] = ttest2(dists_all{combos(i, 1)}, dists_all{combos(i, 2)});
end
disp(p)

%% (E)
dists_all = distance_traveled_lags(regions, colors);

if WRITE_SOURCE
    writematrix(dists_all{1}, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'E_LEC');
    writematrix(dists_all{2}, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'E_MEC');
    writematrix(dists_all{3}, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'E_CA1');
end

%% (F)
acc_all = decoding(regions, colors);

if WRITE_SOURCE
    values = arrayfun(@(x) {x}, cell2mat(acc_all(:)'))';
    labels = [repmat({'LEC'}, length(acc_all{1}), 1); repmat({'MEC'}, length(acc_all{2}), 1); repmat({'CA1'}, length(acc_all{3}), 1); repmat({'Shuffle'}, length(acc_all{4}), 1)];
    data = [values, labels];
    writecell(data, 'N:\benjamka\events\figures\source_data_Fig1.xlsx', 'Sheet', 'F');
end

combos = [1, 2; 1, 3; 2, 3; 1, 4; 2, 4; 3, 4];
clear p
for i = 1:size(combos, 1)
    [~, p(i)] = ttest2(acc_all{combos(i, 1)}, acc_all{combos(i, 2)});
end
disp(p)
