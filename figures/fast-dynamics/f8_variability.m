

function pv_all = f8_variability

ds = dir('N:\benjamka\events\data\figure-eight\fastDynamics');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'smat_n'}, 1, length(names)), 'uniformoutput', false)));
smat_names = names(inds);

all_cells = [];
pos_cells = [];
neg_cells = [];
rng('default')
for iSession = 1:length(smat_names)
    load(fullfile(ds(1).folder, smat_names{iSession}))
    smat_trial_ave = epoch_ave(smat_n, epochs);
    [~, max_ind] = max(smat_trial_ave, [], 2);
    [~, min_ind] = min(smat_trial_ave, [], 2);
    pos_resp = smat_n(max_ind == 4, epochs == 4) - smat_n(max_ind == 4, epochs == 3);
    neg_resp = smat_n(min_ind == 4, epochs == 4) - smat_n(min_ind == 4, epochs == 3);
    no_resp = smat_n(max_ind ~= 4 & min_ind ~= 4, epochs == 4) - smat_n(max_ind ~= 4 & min_ind ~= 4, epochs == 3);

    % % sample only pos and neg ensembles
    % n_sample = sum(max_ind == 4) + sum(min_ind == 4);
    % smat_tmp = smat_n(max_ind == 4 | min_ind == 4, :);
    % rng("default")
    % for iSample = 1:50
    %     smat_samp = smat_tmp(randi(size(smat_tmp, 1), n_sample, 1), :);
    %     save(sprintf('N:\\benjamka\\events\\data\\figure-eight\\decoding\\ensemble_resampling\\s%d_only-ensemble_smat_samp_%d.mat', iSession, iSample), 'smat_samp')
    % end
    % 
    % % sample nonsembles
    % smat_tmp = smat_n(max_ind ~= 4 & min_ind ~= 4, :);
    % rng("default")
    % for iSample = 1:50
    %     smat_samp = smat_tmp(randi(size(smat_tmp, 1), n_sample, 1), :);
    %     save(sprintf('N:\\benjamka\\events\\data\\figure-eight\\decoding\\ensemble_resampling\\s%d_non-ensemble_smat_samp_%d.mat', iSession, iSample), 'smat_samp')
    % end
    % 
    % % sample random cells
    % smat_tmp = smat_n;
    % rng("default")
    % for iSample = 1:50
    %     smat_samp = smat_tmp(randi(size(smat_tmp, 1), n_sample, 1), :);
    %     save(sprintf('N:\\benjamka\\events\\data\\figure-eight\\decoding\\ensemble_resampling\\s%d_random_smat_samp_%d.mat', iSession, iSample), 'smat_samp')
    % end

    tmp = npx_banal.corrMat(pos_resp, 1);
    tmp(find(eye(size(tmp)))) = nan;
    pos_pv_all(iSession) = nanmean(tmp(:));
    tmp = npx_banal.corrMat(neg_resp, 1);
    tmp(find(eye(size(tmp)))) = nan;
    neg_pv_all(iSession) = nanmean(tmp(:));

    no_pv = nan(1, 50);
    for iSample = 1:50
        tmp = npx_banal.corrMat(no_resp(randi(size(no_resp, 1), 25), :), 1);
        tmp(find(eye(size(tmp)))) = nan;
        no_pv(iSample) = nanmean(tmp(:));
    end
    no_pv_all(iSession) = nanmean(no_pv);
end

pv_all = [{pos_pv_all}, {neg_pv_all}, {no_pv_all}];

figure, hold on
COLOR = 'k';
for iGroup = 1:length(pv_all)
    plot(iGroup, nanmean(pv_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(pv_all{iGroup}), nanstd(pv_all{iGroup}) / sqrt(sum(~isnan(pv_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(pv_all{iGroup}', 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)
fixPlot(1:3, {'Pos', 'Neg', 'Other'}, '', 'Mean PV correlation')
set(gca,'fontsize', 24)

load figp
xlim([0.5, length(pv_all) + 0.5])
set(gcf,'pos',figp), movegui
