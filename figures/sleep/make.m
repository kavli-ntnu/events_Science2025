
addpath('N:\benjamka\events\figures')
addpath(genpath('N:\benjamka\events\figures\sleep'))
regions = {'LEC', 'MEC', 'CA1'};
colors = [0, 0, 0; 0, 0, 0.8; 0, 0.4, 0; 0.5, 0.5, 0.5]; % last is shuffle
WRITE_SOURCE = 0;

%% (D) trajectories

load('N:\benjamka\events\data\sleep\trajectory_examples.mat');

plot_trajectory_session(REM.score, REM.epochs, REM.axLims)

if WRITE_SOURCE
    scat = findall(gca, 'type', 'scatter');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], scat, 'UniformOutput', false);
    data_epochs = vertcat(data{1});
    data_bins = vertcat(data{2});
    writematrix(data_bins, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'D_REM_bins');
    writematrix(data_epochs, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'D_REM_epochs');
end

plot_trajectory_session(OF.score, OF.epochs, OF.axLims)

if WRITE_SOURCE
    scat = findall(gca, 'type', 'scatter');
    data = arrayfun(@(l) [l.XData(:), l.YData(:)], scat, 'UniformOutput', false);
    data_epochs = vertcat(data{1});
    data_bins = vertcat(data{2});
    writematrix(data_bins, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'D_Foraging_bins');
    writematrix(data_epochs, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'D_Foraging_epochs');
end

% ds = dir('N:\benjamka\events\data\sleep\raw_data4ben2');
% clear names
% for i = 3:length(ds)
%     names{i-2} = ds(i).name;
% end
% inds_OF = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'OF_bin-1000ms'}, 1, length(names)), 'uniformoutput', false)));
% inds_REM = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'REM_bin-1000ms'}, 1, length(names)), 'uniformoutput', false)));
% traj_names_OF = names(inds_OF);
% traj_names_REM = names(inds_REM);
% 
% xl = readcell(fullfile(ds(1).folder, traj_names_REM{ind_rem}));
% smat_n = cell2mat(xl');
% epochLength = 6;
% numEpochs = ceil(size(smat_n, 2) / epochLength);
% epochs = [];
% for iEpoch = 1:numEpochs
%     epochs = [epochs, zeros(1, epochLength) + iEpoch];
% end
% epochs = epochs(1:size(smat_n, 2));
% save('C:\Users\benjamka\OneDrive - NTNU\MATLAB\smat_n.mat', 'smat_n', 'epochs')
% 
% xl = readcell(fullfile(ds(1).folder, traj_names_OF{ind_of}));
% smat_n = cell2mat(xl');
% epochLength = 6;
% numEpochs = ceil(size(smat_n, 2) / epochLength);
% epochs = [];
% for iEpoch = 1:numEpochs
%     epochs = [epochs, zeros(1, epochLength) + iEpoch];
% end
% epochs = epochs(1:size(smat_n, 2));
% save('C:\Users\benjamka\OneDrive - NTNU\MATLAB\smat_n.mat', 'smat_n', 'epochs')
% 
% save('N:\benjamka\events\data\sleep\trajectory_examples.mat', 'REM', 'OF');

%% (E) pv dists

if WRITE_SOURCE
    close all
end

% summary
[dists_REM, dists_OF] = pv_dists('LEC');

if WRITE_SOURCE
    figure(1)
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'E_REM_average');
    figure(2)
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'E_Foraging_average');
end

% examples
ind_rem = 32;
ind_of = 41;

figure('pos', figp)
imagesc(dists_REM(:, :, ind_rem))
c = colorbar;
COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
colormap(gca, flipud(COLOR))
clim([0.441 0.56])
fixPlot([1, 10], num2str([1, 60]'), 'Time (sec)', 'Time (sec)')
set(gca, 'ydir', 'nor', 'ytick', [1, 10], 'yticklabel', num2str([1, 60]'), 'fontsize', 24), axis square, box on
c.Label.String = sprintf('Distance traveled\n(ambient space)');
c.Label.FontSize = 24;
title('REM')

if WRITE_SOURCE
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'E_REM_example');
end

load figp
figure('pos', figp)
imagesc(dists_OF(:, :, ind_of))
c = colorbar;
COLOR = horzcat(linspace(0, 1, 64)', linspace(0, 1, 64)', linspace(0, 1, 64)');
colormap(gca, flipud(COLOR))
clim([0.375 0.5])
fixPlot([1, 10], num2str([1, 60]'), 'Time (sec)', 'Time (sec)')
set(gca, 'ydir', 'nor', 'ytick', [1, 10], 'yticklabel', num2str([1, 60]'), 'fontsize', 24), axis square, box on
c.Label.String = sprintf('Distance traveled\n(ambient space)');
c.Label.FontSize = 24;
title('Foraging')

if WRITE_SOURCE
    im = findall(gca, 'type', 'image');
    data = im.CData;
    writematrix(data, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'E_Foraging_example');
end

%% (F) dists

dists_rem = squeeze(dists_REM(1, end, :));
dists_of = squeeze(dists_OF(1, end, :));
lillietest(dists_of)
[pval, ~, stats] = ranksum(dists_rem, dists_of);
fprintf('U = %0.2f, p = %0.2f, Wilcoxon rank-sum test, n = %d segments\n', stats.ranksum, pval, length(dists_of));

figure
hold on

COLOR = 'k';
plot(1, nanmean(dists_rem), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1, nanmean(dists_rem), nanstd(dists_rem) / sqrt(sum(~isnan(dists_rem))), 'color', COLOR, 'linew', 2)
plotSpread({dists_rem}, 'xvalues', 1, 'distributionColors', COLOR)

plot(2, nanmean(dists_of), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(2, nanmean(dists_of), nanstd(dists_of) / sqrt(sum(~isnan(dists_of))), 'color', COLOR, 'linew', 2)
plotSpread({dists_of}, 'xvalues', 2, 'distributionColors', COLOR)

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:2, {'REM', 'Foraging'}, '', 'Distance traveled')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) * 0.67;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

if WRITE_SOURCE
    values = arrayfun(@(x) {x}, [dists_rem; dists_of]);
    labels = [repmat({'REM'}, length(dists_rem), 1); repmat({'Foraging'}, length(dists_of), 1)];
    data = [values, labels];
    writecell(data, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'F');
end

%% (G) decoding
[acc_REM, acc_of] = decoding;
ylim([0 80])
% [~, p, ~, stats] = vartest2(acc_REM, acc_of)
[pval, ~, stats] = ranksum(acc_REM, acc_of);
fprintf('U = %0.2f, p = %0.2f, Wilcoxon rank-sum test, n = %d segments\n', stats.ranksum, pval, length(acc_of));

if WRITE_SOURCE
    values = arrayfun(@(x) {x}, [acc_REM; acc_of]);
    labels = [repmat({'REM'}, length(acc_REM), 1); repmat({'Foraging'}, length(acc_of), 1)];
    data = [values, labels];
    writecell(data, 'N:\benjamka\events\figures\source_data_Fig2.xlsx', 'Sheet', 'G');
end