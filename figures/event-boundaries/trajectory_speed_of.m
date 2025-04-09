

function [speed_of] = trajectory_speed_of(regions, colors)

figure, hold on
clear speed_pool
for iRegion = 1:length(regions)
    speed_pool = nan(100, 100);
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\traj_speed_epoch_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            speed = tmp.dists_full;
        else
            break
        end
        speed_pool(iPool, 1:size(speed, 2)) = speed;
    end

    % store vals
    speed_pool = minions.removeNans(speed_pool, 'rows', 'all');
    speed_pool = minions.removeNans(speed_pool, 'cols', 'all');
    speed_all{iRegion} = speed_pool;
end

for iGroup = size(regions, 2):-1:1
    COLOR = colors(iGroup, :);
    errorbar(nanmean(speed_all{iGroup}), nanstd(speed_all{iGroup}, [], 1) / sqrt(size(speed_all{iGroup}, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
end

load figp
fixPlot(1:8, num2str([2:9]'), 'Time (min)', 'Change in trajectory speed')
xlim([0.5, 8.5])
plot(xlim, [0, 0], 'k:')
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)

if length(regions) == 1
    speed_of = speed_all{1};
else
    speed_of = speed_all;
end