

function alt_all = f8_alternation

ds = dir('N:\benjamka\events\data\figure-eight\alternation');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end

alt_all = [];
for i = 1:length(names)
    load(fullfile(ds(1).folder, names{i}))
    alt_all = [alt_all, alt];
end

figure, hold on
COLOR = 'k';
plot(1, nanmean(alt_all), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
errorbar(1, nanmean(alt_all), nanstd(alt_all) / sqrt(sum(~isnan(alt_all))), 'color', COLOR, 'linew', 2)
plotSpread(alt_all', 'distributionColors', COLOR)

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
fixPlot(1, '', '', 'Alternation score')
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
ylim([0, 1])
