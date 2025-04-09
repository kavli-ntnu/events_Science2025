

addpath('N:\benjamka\events\figures')
addpath(genpath('N:\benjamka\events\figures\fast-dynamics'))
regions = {'LEC', 'MEC', 'CA1'};
colors = [0, 0, 0; 0, 0, 0.8; 0, 0.4, 0; 0.5, 0.5, 0.5]; % last is shuffle
WRITE_SOURCE = 0;

%% (A) figure-eight
f8_heatmap()

if WRITE_SOURCE
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'A_heatmap');
end

fraction = f8_preferred_time();

if WRITE_SOURCE
    writematrix(fraction, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'A_fraction');
end

rate = f8_magnitude_timecourse();

if WRITE_SOURCE
    writematrix(rate, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'A_rate');
end

%% (B) odor sequence
seq_heatmap()

if WRITE_SOURCE
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'B_heatmap');
end

fraction = seq_preferred_time();

if WRITE_SOURCE
    writematrix(fraction, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'B_fraction');
end

rate = seq_magnitude_timecourse();

if WRITE_SOURCE
    writematrix(rate, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'B_rate');
end

%% (C) novel objects
obj_heatmap()

if WRITE_SOURCE
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'C_heatmap');
end

fraction = obj_preferred_time();

if WRITE_SOURCE
    writematrix(fraction, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'C_fraction');
end

rate = obj_magnitude_timecourse();

if WRITE_SOURCE
    writematrix(rate, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'C_rate');
end

%% (D) example f8 trial variability
load('N:\benjamka\events\data\figure-eight\fastDynamics\smat_n_cedar_12-15_11-47.mat')
smat_trial_ave = epoch_ave(smat_n, epochs);
[~, max_ind] = max(smat_trial_ave, [], 2);
pos_resp = smat_n(max_ind == 4, epochs == 4) - smat_n(max_ind == 4, epochs == 3);
figure
imagesc(pos_resp);
fixPlot
set(gca,'colormap',clr.redblue)
xlabel 'Trial number'
ylabel 'Neuron'

if WRITE_SOURCE
    writematrix(pos_resp, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'D');
end

%% (E) summary f8 trial variability
pv_all = f8_variability;

if WRITE_SOURCE
    values = arrayfun(@(x) {x}, cell2mat(pv_all(:)));
    values = values';
    labels = [repmat({'Pos'}, length(pv_all{1}), 1); repmat({'Neg'}, length(pv_all{2}), 1); repmat({'Other'}, length(pv_all{3}), 1)];
    data = [values(:), labels];
    writecell(data, 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'E');
end

%% (F) decoding f8 trial number
[decodeError, decodeError_sh] = f8_trial_number_decoding;

if WRITE_SOURCE
    writematrix([decodeError', decodeError_sh'], 'N:\benjamka\events\figures\source_data_Fig6.xlsx', 'Sheet', 'F');
end