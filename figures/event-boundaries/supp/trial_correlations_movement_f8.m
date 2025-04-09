

function [traj_speed, animal_speed] = trial_correlations_movement_f8

ds = dir('N:\benjamka\events\data\figure-eight');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed_animal'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj);

traj_speed = [];
animal_speed = [];
clear r2_store p_store
for i = 1:length(traj_names)
    load(fullfile(ds(1).folder, traj_names{i}))
    traj_speed = [traj_speed; trial_traj_acc]; 
    animal_speed = [animal_speed; trial_animal_acc / 100]; % convert to m/sec

    [r, pval] = corrcoef(trial_animal_acc(:, 2), trial_traj_acc(:, 2));
    r2_store(i) = r(1, 2) ^ 2;
    p_store(i) = pval(1, 2);
end

%% 
figure
plot(animal_speed(:, 2), traj_speed(:, 2), 'k.')
[r, p] = corrcoef(animal_speed(:, 2), traj_speed(:, 2));
r2 = r(1, 2) ^ 2;
load figp
set(gcf, 'pos', figp)
fixPlot('', [], 'Change in animal speed (m/s^2)', 'Change in trajectory speed')
text(0.16, 0.38, sprintf('R^2 = %1.4f', r2), 'fontsize', 24)
set(gca, 'fontsize', 24)
disp(p(1, 2))

return
