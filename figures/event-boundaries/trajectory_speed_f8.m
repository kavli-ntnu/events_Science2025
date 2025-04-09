

function speed_f8 = trajectory_speed_f8

ds = dir('N:\benjamka\events\data\figure-eight');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed'}, 1, length(names)), 'uniformoutput', false)));
inds_sh = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'_sh'}, 1, length(names)), 'uniformoutput', false)));
inds_traj_animal = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed_animal'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj & ~inds_sh & ~inds_traj_animal);
traj_names_sh = names(inds_traj & inds_sh & ~inds_traj_animal);

speed_f8 = [];
for i = 1:length(traj_names)
    load(fullfile(ds(1).folder, traj_names{i}))
    speed_f8 = [speed_f8; dists_full];
end

figure, hold on

COLOR = 'k';
errorbar(nanmean(speed_f8), nanstd(speed_f8, [], 1) / sqrt(size(speed_f8, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)

load figp
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf, 'pos', figp_skinny), movegui
fixPlot(1:5, num2str([2:6]'), 'Time (sec)', 'Change in trajectory speed')
xlim([0.5, 5.5])
ylim([-0.12, 0.12])
plot(xlim, [0, 0], 'k:')
set(gca,'fontsize', 24)