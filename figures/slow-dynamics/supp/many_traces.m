
function many_traces(regions, colors)

fano_poiss = 4.6384e-04;
sm_fac = 30;
dt = 0.5;
sm_fac_fast = 1;
sm_fac_slow = 30;

for iRegion = 1:length(regions)
    switch regions{iRegion}
        case 'LEC'
            fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', 'LEC', 15);
        case 'MEC'
            fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', 'MEC', 6);
        case 'CA1'
            fname = sprintf('N:\\benjamka\\events\\data\\foraging_500ms\\glm_%s_%d.mat', 'CA1', 1);
    end
    tmp = load(fname);
    smat_n = tmp.smat_n;
    N = size(smat_n, 1);
    smat_all = [];
    clear fano_store
    
    for i = 1:N
        smat_all = [smat_all; smat_n(i, :)];
        sm_rate = general.smooth(smat_n(i, :), sm_fac / 0.5);
        fano_store(i) = log((var(sm_rate) / mean(sm_rate)) / fano_poiss);
    end
    smat_all_sm = general.smooth(smat_all, [0, sm_fac / 0.5]);
    [~, sind] = sort(fano_store, 'descend');
    
    nr = 10;
    nc = 5;
    sub_pos = npx_banal.subs(nr, nc, 1, 'vertical');
    cnt = 1;
    for ir = 1:nr
        for ic = 1:nc
            axes('pos', sub_pos{ir, ic});
            plot(general.smooth(smat_all(sind(cnt), :), sm_fac_fast  / dt), 'color', [colors(iRegion, :), 0.3])
            hold on
            plot(general.smooth(smat_all(sind(cnt), :), sm_fac_slow  / dt), 'color', colors(iRegion, :), 'linew', 2)
            xlim([1, size(smat_all, 2) + 1])
            text(mean(xlim()), max(ylim()) * 0.9, sprintf('%1.2f', fano_store(sind(cnt))), 'horizontalalignment', 'center')
            axis off
            cnt = cnt + 1;
        end
    end
    
    set(gcf, 'pos', [0.2078    0.0493    0.3253    0.8500])
    
end