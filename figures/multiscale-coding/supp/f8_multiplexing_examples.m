
function f8_multiplexing_examples

load('N:\benjamka\events\data\figure-eight\f8_multiplexing_examples.mat')

example_inds = [1, 1; ...
                3, 2; ...
                5, 4; ...
                10, 8; ...
                11, 11];
plt_inds = [1, 4, 2, 5, 3, 6];


for iExample = 1:size(example_inds, 1)

    sind = [coeff_sort_inds_s(example_inds(iExample, 1)) + 1, coeff_sort_inds_t(example_inds(iExample, 2)) + 1];

    % session time
    smat_all = smat_n_session;
    dt = 0.5;
    sm_fac_fast = 1;
    sm_fac_slow = 30;
    figure('pos', [ 83   317   437 * 1.5   420])
    N_plt = 2;
    cnt = 0;
    for i = 1:N_plt
        cnt = cnt + 1;
        subplot(2, 3, plt_inds(cnt))
        plot(general.smooth(smat_all(sind(i), :), sm_fac_fast  / dt), 'color', [0, 0, 0, 0.3])
        hold on
        plot(general.smooth(smat_all(sind(i), :), sm_fac_slow  / dt), 'color', 'k', 'linew', 2)
        xlim([1, size(smat_all, 2) + 1])
        fixPlot([1, 601, 1201], {'0', '5', '10'}, 'Session time (min)', 'Norm firing rate')
        box off
    end

    % trial time
    smat_all = smat_n_trial_ave;
    dt = 0.05;
    sm_fac_fast = 0;
    sm_fac_slow = 0.5;
    for i = 1:N_plt
        cnt = cnt + 1;
        subplot(2, 3, plt_inds(cnt))
        plot(general.smooth(smat_all(sind(i), :), sm_fac_fast  / dt), 'color', [0, 0, 0, 0.3])
        hold on
        plot(general.smooth(smat_all(sind(i), :), sm_fac_slow  / dt), 'color', 'k', 'linew', 2)
        xlim([1, size(smat_all, 2) + 1])
        fixPlot([1, 61, 121], {'0', '3', '6'}, 'Trial time (sec)', 'Norm firing rate')
        box off
    end

    % splitting early vs late trials
    for i = 1:N_plt
        cnt = cnt + 1;
        subplot(2, 3, plt_inds(cnt))
        plot(general.smooth(smat_n_trial_ave_early(sind(i), :), sm_fac_slow  / dt), 'k:', 'linew', 2)
        hold on
        plot(general.smooth(smat_n_trial_ave_late(sind(i), :), sm_fac_slow  / dt), 'k--', 'linew', 2)
        xlim([1, size(smat_all, 2) + 1])
        fixPlot([1, 61, 121], {'0', '3', '6'}, 'Trial time (sec)', 'Norm firing rate')
        box off
    end

end