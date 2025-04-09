

function ITI_all = f8_ITI

ds = dir('N:\benjamka\events\data\figure-eight\ITI');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end

ITI_all = nan(length(names), 100);
for i = 1:length(names)
    load(fullfile(ds(1).folder, names{i}))
    ITI_all(i, 1:length(ITI)) = ITI;
end

figure, hold on
COLOR = 'k';
for iGroup = 1:length(names)
    plot(iGroup, nanmean(ITI_all(iGroup, :)), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(ITI_all(iGroup, :)), nanstd(ITI_all(iGroup, :)) / sqrt(sum(~isnan(ITI_all(iGroup, :)))), 'color', COLOR, 'linew', 2)
    plotSpread(ITI_all(iGroup, :)', 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:length(names), [], '', 'Intertrial interval (sec)')
xlabel 'Session'
xlim([0.5, length(names) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)