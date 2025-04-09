
function [r2_store, p_store] = trajectory_speed_vs_movement_of

ds = dir('N:\benjamka\events\data\foraging_1s');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n_LEC'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj);

clear r2_store p_store
for i = 1:length(traj_names)
    load(fullfile(ds(1).folder, traj_names{i}))

    traj_acc = diff(diag(squareform(pdist(smat_n', 'cosine')), -1));
    spd_downsampled = spd_sm(round(linspace(1, length(spd_sm), size(smat_n, 2))));
    animal_acc = diff(spd_downsampled(2:end));

    [r, pval] = corrcoef(animal_acc, traj_acc);
    r2_store(i) = r(1, 2) ^ 2;
    p_store(i) = pval(1, 2);
end

return

%% correlation between trajectory and rat acceleration

load('N:\benjamka\events\data\foraging_1s\smat_n_LEC_17.mat')
traj_acc = diff(diag(squareform(pdist(smat_n', 'cosine')), -1));
spd_downsampled = spd_sm(round(linspace(1, length(spd_sm), size(smat_n, 2))));
animal_acc = diff(spd_downsampled(2:end));

figure
plot(animal_acc, traj_acc, 'k.')
mx = max([animal_acc(:); traj_acc(:)],[],'all');
axis([-mx, mx, -mx, mx])
[r, pval] = corrcoef(animal_acc, traj_acc);
set(findobj(gca, 'type', 'line'), 'color', 'k')
load figp
set(gcf, 'pos', figp)
fixPlot
xlabel('Change in animal speed (m/s^2)')
ylabel('Change in trajectory speed')
text(0.16, 0.38, sprintf('R^2 = %1.4f\np = %1.4f', r(1,2) ^ 2, pval(1, 2)), 'fontsize', 24)
set(gca, 'fontsize', 24)


end