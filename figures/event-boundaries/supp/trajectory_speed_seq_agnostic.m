
function [fraction_seq, fraction_occ] = trajectory_speed_seq_agnostic

ds = dir('N:\benjamka\events\data\sequence');
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

fraction_seq = [];
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

    inds_cen = posX(rate_change_pos_inds) < 0.2 & posX(rate_change_pos_inds) > -0.2;

    figure
    plot(posX, posY, '-', 'color', [0.8 0.8 0.8])
    hold on
    plot(posX(rate_change_pos_inds), posY(rate_change_pos_inds), 'ro', 'linew', 2)
    plot([-0.5 0.5], [0.3 0.3], 'k:')
    
    fraction_seq = [fraction_seq; sum(inds_cen) / length(rate_change_pos_inds)];

    inds_cen_occ = posX < 0.2 & posX > -0.2;
    fraction_occ = [fraction_occ; sum(inds_cen_occ) / length(posX)];

    % Observed values
    O_XY = sum(inds_cen);
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

nanmean(fraction_seq)
nanstd(fraction_seq) / sqrt(sum(~isnan(fraction_seq)))

nanmean(fraction_occ)
nanstd(fraction_occ) / sqrt(sum(~isnan(fraction_occ)))




