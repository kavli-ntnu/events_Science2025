

function dists_all = seq_trial_number_variability(regions, colors)

ds = dir('N:\benjamka\events\data\sequence');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n_trial'}, 1, length(names)), 'uniformoutput', false)));
names = names(inds);

dists_pool = [];
for iSession = 1:length(names)
    load(fullfile(ds(1).folder, names{iSession}))

    starts = epochs == 1;
    new_epochs = nan(1, length(epochs));
    cnt = 0;
    for i = 1:length(epochs)
        if starts(i)
            cnt = cnt + 1;
        end
        new_epochs(i) = cnt;
    end
    smat_trial_ave = epoch_ave(smat_n, new_epochs);
    tmp = squareform(pdist(smat_trial_ave', 'cosine'));
    tmp(find(eye(size(tmp)))) = nan;
    dists_pool = [dists_pool, nanmean(tmp(:))];
end

dists_all{1} = dists_pool;

dists_pool = [];
rng("default")
for iSession = 1:length(names)
    load(fullfile(ds(1).folder, names{iSession}))

    starts = epochs == 1;
    new_epochs = nan(1, length(epochs));
    cnt = 0;
    for i = 1:length(epochs)
        if starts(i)
            cnt = cnt + 1;
        end
        new_epochs(i) = cnt;
    end
    new_epochs = new_epochs(randperm(length(new_epochs)));
    smat_trial_ave = epoch_ave(smat_n, new_epochs);
    tmp = squareform(pdist(smat_trial_ave', 'cosine'));
    tmp(find(eye(size(tmp)))) = nan;
    dists_pool = [dists_pool, nanmean(tmp(:))];
end
dists_all{4} = dists_pool;
%

ds = dir('N:\benjamka\events\data\sequence\MEC');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n_trial'}, 1, length(names)), 'uniformoutput', false)));
names = names(inds);

dists_pool = [];
for iSession = 1:length(names)
    load(fullfile(ds(1).folder, names{iSession}))

    starts = epochs == 1;
    new_epochs = nan(1, length(epochs));
    cnt = 0;
    for i = 1:length(epochs)
        if starts(i)
            cnt = cnt + 1;
        end
        new_epochs(i) = cnt;
    end
    smat_trial_ave = epoch_ave(smat_n, new_epochs);
    tmp = squareform(pdist(smat_trial_ave', 'cosine'));
    tmp(find(eye(size(tmp)))) = nan;
    dists_pool = [dists_pool, nanmean(tmp(:))];
end

dists_all{2} = dists_pool;

%

ds = dir('N:\benjamka\events\data\sequence\CA1');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n_trial'}, 1, length(names)), 'uniformoutput', false)));
names = names(inds);

dists_pool = [];
for iSession = 1:length(names)
    load(fullfile(ds(1).folder, names{iSession}))

    starts = epochs == 1;
    new_epochs = nan(1, length(epochs));
    cnt = 0;
    for i = 1:length(epochs)
        if starts(i)
            cnt = cnt + 1;
        end
        new_epochs(i) = cnt;
    end
    smat_trial_ave = epoch_ave(smat_n, new_epochs);
    tmp = squareform(pdist(smat_trial_ave', 'cosine'));
    tmp(find(eye(size(tmp)))) = nan;
    dists_pool = [dists_pool, nanmean(tmp(:))];
end

dists_all{3} = dists_pool;

figure, hold on
for iGroup = 1:length(dists_all)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(dists_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(dists_all{iGroup}), nanstd(dists_all{iGroup}) / sqrt(sum(~isnan(dists_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(dists_all{iGroup}', 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)
fixPlot(1:length(dists_all), [regions, 'Shuffle'], '', sprintf('Mean cosine distance\nbetween trials'))
set(gca,'fontsize', 24)

load figp
xlim([0.5, length(dists_all) + 0.5])
ylim([0 0.2])
set(gcf,'pos',figp), movegui