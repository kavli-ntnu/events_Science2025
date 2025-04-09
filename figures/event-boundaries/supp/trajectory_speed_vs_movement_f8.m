
function [r2_store, p_store] = trajectory_speed_vs_movement_f8

ds = dir('N:\benjamka\events\data\figure-eight\smat_full_1s');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
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

%% use final session already loaded as example
figure
plot(animal_acc, traj_acc, 'k.')
mx = max([animal_acc(:); traj_acc(:)],[],'all');
axis([-mx, mx, -mx, mx])
[r, pval] = corrcoef(animal_acc, traj_acc);
load figp
set(gcf, 'pos', figp)
fixPlot
xlabel('Change in animal speed (m/s^2)')
ylabel('Change in trajectory speed')
text(0.16, 0.38, sprintf('R^2 = %1.4f\np = %1.4f', r(1,2) ^ 2, pval(1, 2)), 'fontsize', 24)
set(gca, 'fontsize', 24)

%% summary figure
figure, plot(r2_store, p_store, 'ko')
load figp
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) * 0.67;
set(gcf,'pos',figp_skinny), movegui
fixPlot([0, 0.006], [], 'Explained variance', 'p-value')
set(gca,'fontsize', 24)
hold on, plot([0 max(xlim)], [0.05 0.05], 'r-')


end