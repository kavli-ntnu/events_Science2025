

function dists_all = distance_traveled_simultaneous

fig_lines = figure('pos', [350, 154, 829, 599]); movegui
hold on
fig_dots = figure('pos', [118, 365, 1207, 355]); movegui
hold on

regions = {'LEC', 'MEC'};
simultaneous_inds = [10:26; 
                     [1:13, 15:18]];
clear dists_pool
for iRegion = 1:length(regions)
    dists_pool = [];
    for iPool = simultaneous_inds(iRegion, :)
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\dists_endpt_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            dists = tmp.dists_full;
        else
            break
        end
        dists_pool = [dists_pool, dists(end, 1)];
    end

    % store vals
    tmp = dists_pool;
    dists_all{iRegion} = tmp(~isnan(tmp));
end

figure(fig_lines)
subplot(1, 3, 1)
plot([dists_all{1}; dists_all{2}], 'k-')
axis([0.75 2.25 0.05 0.35])
fixPlot(1:2, {'LEC', 'MEC'}, '', 'Distance traveled')
[~, p, ~, stats] = ttest2(dists_all{1}, dists_all{2})

regions = {'LEC', 'CA1'};
simultaneous_inds = [[15:18, 20:26]; 
                     [1:7, 9:12]];
clear dists_pool
for iRegion = 1:length(regions)
    dists_pool = [];
    for iPool = simultaneous_inds(iRegion, :)
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\dists_endpt_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            dists = tmp.dists_full;
        else
            break
        end
        dists_pool = [dists_pool, dists(end, 1)];
    end

    % store vals
    tmp = dists_pool;
    dists_all{iRegion} = tmp(~isnan(tmp));
end

figure(fig_lines)
subplot(1, 3, 2)
plot([dists_all{1}; dists_all{2}], 'k-')
axis([0.75 2.25 0.05 0.35])
fixPlot(1:2, {'LEC', 'CA1'}, '', 'Distance traveled')
[~, p, ~, stats] = ttest2(dists_all{1}, dists_all{2})

regions = {'MEC', 'CA1'};
simultaneous_inds = [[6:9, 11:18];
                    1:12];
clear dists_pool
for iRegion = 1:length(regions)
    dists_pool = [];
    for iPool = simultaneous_inds(iRegion, :)
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\dists_endpt_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            dists = tmp.dists_full;
        else
            break
        end
        dists_pool = [dists_pool, dists(end, 1)];
    end

    % store vals
    tmp = dists_pool;
    dists_all{iRegion} = tmp(~isnan(tmp));
end

figure(fig_lines)
subplot(1, 3, 3)
plot([dists_all{1}; dists_all{2}], 'k-')
axis([0.75 2.25 0.05 0.35])
fixPlot(1:2, {'MEC', 'CA1'}, '', 'Distance traveled')
[~, p, ~, stats] = ttest2(dists_all{1}, dists_all{2})
