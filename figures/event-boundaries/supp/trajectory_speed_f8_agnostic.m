
function fraction_f8 = trajectory_speed_f8_agnostic

ds = dir('N:\benjamka\events\data\figure-eight');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'pos_full'}, 1, length(names)), 'uniformoutput', false)));
pos_names = names(inds);

O_XY_pool = [];
O_XnY_pool = [];
O_nXY_pool = [];
O_nXnY_pool = [];
fraction_f8 = [];
fraction_occ = [];
for iSession = 1:length(pos_names)
    load(fullfile(ds(1).folder, pos_names{iSession}))

    dt = 1; % sec
    [~, smat_n] = npx_banal.binSpikes(sCell,posT,dt);
    timeInt = posT(1):dt:posT(end);

    % find times of high rate and rate change
    thresh = 90;

    pop_rate = mean(smat_n(:, 2:end), 1);
    clear df
    for i = 2:size(smat_n, 2)
        df(i-1) = sum(smat_n(:, i) - smat_n(:, i - 1));
    end
    df = df / size(smat_n, 1);

    rate_change_inds = find(pop_rate > prctile(pop_rate, thresh) & df > prctile(df, thresh));
    rate_change_times = timeInt(rate_change_inds + 1);
    rate_change_pos_inds = knnsearch(posT, rate_change_times');

    % exclude stationary periods far from reward site
    inds_slow = spd_sm(rate_change_pos_inds) < 0.2;
    inds_rew = posX(rate_change_pos_inds) < 0.3 & posX(rate_change_pos_inds) > -0.3 & posY(rate_change_pos_inds) > 0.5;
    rate_change_pos_inds(inds_slow & ~inds_rew) = [];

    figure
    plot(posX, posY, '-', 'color', [0.8 0.8 0.8])
    hold on
    plot(posX(rate_change_pos_inds), posY(rate_change_pos_inds), 'ro', 'linew', 2)
    
    fraction_f8 = [fraction_f8; sum(inds_rew) / length(rate_change_pos_inds)];

    inds_rew_occ = posX < 0.3 & posX > -0.3 & posY > 0.5;
    fraction_occ = [fraction_occ; sum(inds_rew_occ) / length(posX)];
    
    % Observed values
    O_XY = sum(inds_rew);
    O_XnY = length(rate_change_times) - O_XY;
    O_nXY = round((sum((posX < 0.2) & (posX > -0.2)) / length(posT)) * (length(timeInt) - 1)) - O_XY;
    O_nXnY = (length(timeInt) - 1) - O_XnY - O_nXY;

    O_XY_pool = [O_XY_pool, O_XY];
    O_XnY_pool = [O_XnY_pool, O_XnY];
    O_nXY_pool = [O_nXY_pool, O_nXY];
    O_nXnY_pool = [O_nXnY_pool, O_nXnY];
end

table = [sum(O_XY_pool), sum(O_XnY_pool); sum(O_nXY_pool), sum(O_nXnY_pool)];

% Fisher’s Exact Test
[h, p] = fishertest(table);
disp(['Fisher’s Exact Test p-value: ', num2str(p)]);

figure, hold on

COLOR = 'k';
plot(1:2, [fraction_f8, fraction_occ], '-', 'color', COLOR, 'linew', 1)
plot(1:2, [nanmean(fraction_f8), nanmean(fraction_occ)] , 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
err1 = nanstd(fraction_f8) / sqrt(sum(~isnan(fraction_f8)));
err2 = nanstd(fraction_occ) / sqrt(sum(~isnan(fraction_occ)));
errorbar(1:2, [nanmean(fraction_f8), nanmean(fraction_occ)],[err1, err2] , 'color', COLOR, 'linew', 2)

load figp
fixPlot(1:2, {'Sync', 'All'}, '', 'Fraction near reward')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)
ylim([0, 1])



