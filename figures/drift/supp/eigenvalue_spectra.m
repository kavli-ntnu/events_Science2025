
%% explained variance
store_LEC = nan(26, 59);

for iSession = 1:26
    fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', 'LEC', iSession);
    tmp = load(fname);
    smat_n = tmp.smat_n;
    [coeff,score,latent,tsquared,explained,mu] = pca(smat_n');
    tmp = explained;
    store_LEC(iSession, 1:length(tmp)) = tmp;
end

store_MEC = nan(18, 59);
for iSession = 1:18
    fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', 'MEC', iSession);
    tmp = load(fname);
    smat_n = tmp.smat_n;
    [coeff,score,latent,tsquared,explained,mu] = pca(smat_n');
    tmp = explained;
    store_MEC(iSession, 1:length(tmp)) = tmp;
end

store_CA1 = nan(12, 59);
for iSession = 1:12
    fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', 'CA1', iSession);
    tmp = load(fname);
    smat_n = tmp.smat_n;
    [coeff,score,latent,tsquared,explained,mu] = pca(smat_n');
    tmp = explained;
    store_CA1(iSession, 1:length(tmp)) = tmp;
end

figure, hold on
plot(nanmean(store_LEC), '.', 'color', colors(1, :), 'linew', 5, 'markersize', 20)
errorbar(nanmean(store_LEC), nanstd(store_LEC) ./ sqrt(sum(~isnan(store_LEC))), 'color', colors(1, :), 'linew', 2)
plot(nanmean(store_MEC), '.', 'color', colors(2, :), 'linew', 5, 'markersize', 20)
errorbar(nanmean(store_MEC), nanstd(store_MEC) ./ sqrt(sum(~isnan(store_MEC))), 'color', colors(2, :), 'linew', 2)
plot(nanmean(store_CA1), '.', 'color', colors(3, :), 'linew', 5, 'markersize', 20)
errorbar(nanmean(store_CA1), nanstd(store_CA1) ./ sqrt(sum(~isnan(store_CA1))), 'color', colors(3, :), 'linew', 2)

load figp
fixPlot(1:10, [], 'Principal component', 'Explained variance (%)')
xlim([0.5 10.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

if WRITE_SOURCE
    writematrix(store_LEC, 'N:\benjamka\events\figures\source_data_SuppFigS4.xlsx', 'Sheet', 'A_LEC');
    writematrix(store_MEC, 'N:\benjamka\events\figures\source_data_SuppFigS4.xlsx', 'Sheet', 'A_MEC');
    writematrix(store_CA1, 'N:\benjamka\events\figures\source_data_SuppFigS4.xlsx', 'Sheet', 'A_CA1');
end

%% PCs explaining 50%
for i = 1:size(store_LEC, 1)
    numPCs{1}(i) = find(cumsum(store_LEC(i, :)) > 50, 1);
end
for i = 1:size(store_MEC, 1)
    numPCs{2}(i) = find(cumsum(store_MEC(i, :)) > 50, 1);
end
for i = 1:size(store_CA1, 1)
    numPCs{3}(i) = find(cumsum(store_CA1(i, :)) > 50, 1);
end

figure, hold on
for iGroup = 1:size(regions, 2)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(numPCs{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(numPCs{iGroup}), nanstd(numPCs{iGroup}) / sqrt(sum(~isnan(numPCs{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(numPCs(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(regions, 2), regions, '', 'PCs explaining 50% of variance')
xlim([0.5, size(regions, 2) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)

if WRITE_SOURCE
    values = arrayfun(@(x) {x}, cell2mat(numPCs(:)'))';
    labels = [repmat({'LEC'}, length(numPCs{1}), 1); repmat({'MEC'}, length(numPCs{2}), 1); repmat({'CA1'}, length(numPCs{3}), 1)];
    data = [values, labels];
    writecell(data, 'N:\benjamka\events\figures\source_data_SuppFigS4.xlsx', 'Sheet', 'B');
end

%% PC examples over time
fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', 'LEC', 15);
tmp = load(fname);
smat_n = tmp.smat_n;
[coeff,score,latent,tsquared,explained,mu] = pca(smat_n');
figure
for iPC = 1:3
    subplot(3, 1, iPC)
    plot(score(:, iPC), '-', 'color', colors(1, :), 'linew', 2)
    fixPlot([0, 30, 60], {'0', '5',' 10'}, '', sprintf('PC%d', iPC))
    set(gca, 'yticklabels', {})
    if iPC == 3
        xlabel('Time (min)')
    else
        set(gca, 'xticklabels', {})
    end
    mx = max(abs(score(:)));
    ylim([-mx mx])
end

if WRITE_SOURCE
    writematrix(score(:, 1:3), 'N:\benjamka\events\figures\source_data_SuppFigS4.xlsx', 'Sheet', 'C_LEC');
end
%
fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', 'MEC', 6);
tmp = load(fname);
smat_n = tmp.smat_n;
[coeff,score,latent,tsquared,explained,mu] = pca(smat_n');
figure
for iPC = 1:3
    subplot(3, 1, iPC)
    plot(score(:, iPC), '-', 'color', colors(2, :), 'linew', 2)
    fixPlot([0, 30, 60], {'0', '5',' 10'}, '', sprintf('PC%d', iPC))
    set(gca, 'yticklabels', {})
    if iPC == 3
        xlabel('Time (min)')
    else
        set(gca, 'xticklabels', {})
    end
    mx = max(abs(score(:)));
    ylim([-mx mx])
end

if WRITE_SOURCE
    writematrix(score(:, 1:3), 'N:\benjamka\events\figures\source_data_SuppFigS4.xlsx', 'Sheet', 'C_MEC');
end
%
fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', 'CA1', 1);
tmp = load(fname);
smat_n = tmp.smat_n;
[coeff,score,latent,tsquared,explained,mu] = pca(smat_n');
figure
for iPC = 1:3
    subplot(3, 1, iPC)
    plot(score(:, iPC), '-', 'color', colors(3, :), 'linew', 2)
    fixPlot([0, 30, 60], {'0', '5',' 10'}, '', sprintf('PC%d', iPC))
    set(gca, 'yticklabels', {})
    if iPC == 3
        xlabel('Time (min)')
    else
        set(gca, 'xticklabels', {})
    end
    mx = max(abs(score(:)));
    ylim([-mx mx])
end

if WRITE_SOURCE
    writematrix(score(:, 1:3), 'N:\benjamka\events\figures\source_data_SuppFigS4.xlsx', 'Sheet', 'C_CA1');
end

% %% GLM to find significant ramps
% fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\smat_n_%s_%d.mat', 'LEC', 15);
% tmp = load(fname);
% smat_n = tmp.smat_n;
% predPopRate = nanmean(smat_n);
% predTimeLinear = linspace(0, 1, size(smat_n,2));
% X = [predPopRate; predTimeLinear]';
% clear b stats p
% for iNeuron = 1:size(smat_n,1)
%     [b(iNeuron,:),~,stats{iNeuron}] = glmfit(X,smat_n(iNeuron,:),'poisson');
%     p(iNeuron,:) = stats{iNeuron}.p;
%     exp_var(iNeuron) = 1 - var(stats{iNeuron}.resid) ./ var(smat_n(iNeuron,:));
% end
% [~,sind] = sort(p(:,3),'ascend','missing','last');
