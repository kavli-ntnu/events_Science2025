

function fano_all = fano_factor(regions, colors)

sm_fac = 30;
fano_poiss = 4.6384e-04; % mean for poiss with 30 sec smoothing (4.6384e-04 with dt 0.5) (0.0044 with dt 10)
dt = 0.5;
clear fano_pool

for iRegion = 1:length(regions)
    fano_pool = [];
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
                fano(cnt) = (var(sm_rate) / mean(sm_rate)) / fano_poiss;
            end
        else
            break
        end
        fano_pool = [fano_pool; mean(log(fano))];
    end

    % store vals
    fano_all{iRegion} = fano_pool;
    
end

figure, hold on
for iGroup = 1:length(fano_all)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(fano_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(fano_all{iGroup}), nanstd(fano_all{iGroup}) / sqrt(sum(~isnan(fano_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(fano_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(colors, 1), [regions, {'Shuffle'}], '', 'Mean normalized fano factor')
xlim([0.5, size(colors, 1) + 0.5 - 1])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
