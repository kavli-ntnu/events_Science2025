

function [traj_speed, animal_speed] = trial_correlations_movement_seq

ds = dir('N:\benjamka\events\data\sequence');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_traj = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'traj_speed_animal'}, 1, length(names)), 'uniformoutput', false)));
traj_names = names(inds_traj);

traj_speed = [];
animal_speed = [];
clear r2_store p_store
for i = [1:4,10]
    load(fullfile(ds(1).folder, traj_names{i}))
    traj_speed = [traj_speed; trial_traj_acc];
    animal_speed = [animal_speed; trial_animal_acc];

    [r, pval] = corrcoef(trial_animal_acc(:, 10), trial_traj_acc(:, 10));
    r2_store(i) = r(1, 2) ^ 2;
    p_store(i) = pval(1, 2);
end

%% 
figure
plot(animal_speed(:, 10), traj_speed(:, 10), 'k.')
[r, p] = corrcoef(animal_speed(:, 10), traj_speed(:, 10));
r2 = r(1, 2) ^ 2;
load figp
set(gcf, 'pos', figp)
fixPlot('', [], 'Change in animal speed (m/s^2)', 'Change in trajectory speed')
text(0.2, -0.2, sprintf('R^2 = %1.4f', r2), 'fontsize', 24)
set(gca, 'fontsize', 24)
disp(p(1, 2))

return

%%
fnames = {'elm_06-30_10-02', 'elm_06-30_12-56', 'elm_07-01_08-01', 'elm_07-01_12-24', ...
    'juniper_09-17_13-18', 'juniper_09-18_14-13', 'juniper_09-19_11-14', 'juniper_09-20_10-22', ...
    'juniper_09-20_13-14', 'juniper_09-24_14-19'};
for iName = 1:length(fnames)
    load(['N:\benjamka\events\data\sequence\mazeTimestamps_', fnames{iName}, '.mat'])
    load(['N:\benjamka\events\data\sequence\pos_full_', fnames{iName}, '.mat'])
    trialLength = millTimes(2:15, 1) - doorTimes(1:14, 1);
    trialLength(5:5:end) = [];
    min_trial_length = floor(min(trialLength));
    min_trial_length = min(min_trial_length, 27); % don't allow very long trials of immobility
    min_mill_time = floor(min(millTimes(:,2) - millTimes(:,1)));

    trialStarts = [];
    trialEnds = [];
    for iDoor = 1:15
        mn = millTimes(iDoor, 1); % from millStart
        mx = mn + min_trial_length + min_mill_time + 1; % match shortest full trial

        if mx > max(posT)
            mx = max(posT);
        end

        trialStarts = [trialStarts, mn];
        trialEnds = [trialEnds, mx];
    end
    trialStarts = knnsearch(posT, trialStarts');
    trialEnds = knnsearch(posT, trialEnds');
    trialStarts = trialStarts - 1;
    trialEnds = trialEnds - 1;
    save(['N:\benjamka\events\data\sequence\pos_full_', fnames{iName}, '.mat'], 'spd_sm', 'trialEnds', 'trialStarts', '-append')
end


%%

x = speed_seq_trial_LEC(:, 10);
y = speed_seq_trial_CA1(:, 10);

figure, plot(x, y, 'ko')
mx = max(axis());
mn = min(axis());
axis([mn mx mn mx])
[r, p] = corrcoef(x, y)
