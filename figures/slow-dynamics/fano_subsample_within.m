

function dist_sub = fano_subsample_within(regions, colors)

sm_fac = 30;
dt = 0.5;
if dt == 0.5
    fano_poiss = 4.6384e-04; % mean for poiss with sm_fac = 30 sec 
elseif dt == 10
    fano_poiss = 0.0044;
end

rng('default')

for iRegion = 1:length(regions)
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            smat_n = tmp.smat_n;
            N = size(smat_n, 1);
            fano = nan(N, 1);
            cnt = 0;
            for j = 1:N
                cnt = cnt + 1;
                sm_rate = general.smooth(smat_n(j, :), sm_fac / dt);
                fano(cnt) = log((var(sm_rate) / mean(sm_rate)) / fano_poiss);
            end
            [~, sortInd] = sort(fano, 'descend');
            fname = sprintf('N:\\benjamka\\events\\data\\foraging\\smat_n_%s_%d.mat', regions{iRegion}, iPool);
            tmp = load(fname);
            smat_n = tmp.smat_n;
            epochs = tmp.epochs;

            smat_n_full = smat_n;

            % random sample vs random sample after top 25% removed
            n_blocks = 4;
            inds1 = 1;
            inds2 = inds1 + round(N / n_blocks);
            inds = inds1:inds2;

            smat_n = smat_n_full(datasample(1:N, length(inds), 'replace', false), :); % random 25%
            total_dist = calculate_pv_distance(smat_n, epochs);
            dist_sub{iRegion}(iPool, 1) = total_dist;

            smat_n = smat_n_full(sortInd((max(inds)+1):end), :); % remove top cells
            smat_n = smat_n(datasample(1:size(smat_n, 1), length(inds), 'replace', false), :); % random 25%
            total_dist = calculate_pv_distance(smat_n, epochs);
            dist_sub{iRegion}(iPool, 2) = total_dist;

        else
            break
        end
    end
end

figure
hold on
for iRegion = 1:length(regions)
    COLOR = colors(iRegion, :);
    plot(1:2, nanmean(dist_sub{iRegion}, 1), '.', 'color', COLOR, 'markersize', 30)
    errorbar(1:2, nanmean(dist_sub{iRegion}, 1), nanstd(dist_sub{iRegion}, [], 1) / sqrt(size(dist_sub{iRegion}, 1)), 'color', COLOR, 'linew', 2)
end
fixPlot(1:2, {'Control', 'High fano removed'}, '', 'Distance traveled')
set(gca, 'fontsize', 24)
load figp
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) * 0.67;
set(gcf,'pos',figp_skinny), movegui
axis([0.5 2.5 0.1 0.25])
rotateXLabels(gca, 0)
