

function [speed_of] = animal_speed_of(regions, colors)

figure, hold on
clear acc_pool
for iRegion = 1:length(regions)
    acc_pool = nan(100, 100);
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_spd_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            smat_spd = tmp.smat_spd;
            smat_spd = smat_spd(1:6:end); % downsample to epoch
            animal_acc = diff(smat_spd);
            if length(animal_acc) > 8
                animal_acc = animal_acc(1:8);
            end
        else
            break
        end
        acc_pool(iPool, 1:length(animal_acc)) = animal_acc;
    end

    % store vals
    acc_pool = minions.removeNans(acc_pool, 'rows', 'all');
    acc_pool = minions.removeNans(acc_pool, 'cols', 'all');
    acc_all{iRegion} = acc_pool;
end

for iGroup = size(regions, 2):-1:1
    COLOR = colors(iGroup, :);
    errorbar(nanmean(acc_all{iGroup}), nanstd(acc_all{iGroup}, [], 1) / sqrt(size(acc_all{iGroup}, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)
end

load figp
fixPlot(1:8, num2str([2:9]'), 'Time (min)', 'Change in animal speed (m/s^2)')
xlim([0.5, 8.5])
ylim([-0.5, 0.5])
plot(xlim, [0, 0], 'k:')
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)

speed_of = acc_all{1};
