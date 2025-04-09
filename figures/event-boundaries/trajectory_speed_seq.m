

function speed_seq = trajectory_speed_seq

ds = dir('N:\benjamka\events\data\sequence\trajectorySpeed');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed'}, 1, length(names)), 'uniformoutput', false)));
inds_sh = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'_sh'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj & ~inds_sh);

speed_seq = [];
for i = [1:4, 10] % match behavior across rats
    load(fullfile(ds(1).folder, traj_names{i}))
    speed_seq = [speed_seq; dists_full(1:27)];
end

figure, hold on

COLOR = 'k';
% COLOR = [0	0	0.8];
% COLOR = [0	0.4	0];
errorbar(nanmean(speed_seq), nanstd(speed_seq, [], 1) / sqrt(size(speed_seq, 1)), '.-', 'color', COLOR, 'linew', 2, 'markers', 30)

load figp
fixPlot(1:4:27, num2str([2:4:28]'), 'Time (sec)', 'Change in trajectory speed')
xlim([0.5, size(speed_seq, 2) + 0.5])
ylim([-0.055, 0.055])
plot(xlim, [0, 0], 'k:')
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)