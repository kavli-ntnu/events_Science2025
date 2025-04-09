
function p = anova_rm_boot_mainEffect(X)

% NB: assumes 3 groups and 2 timepoints per group

[p, table] = anova_rm({X{1}, X{2}, X{3}});
F_obs = table{2, 5};

rng(666)
for iRegion = 1:length(X)
    n_rows = size(X{iRegion}, 1);
    tmp_region = nan(n_rows, 2);
    for iRow = 1:n_rows
        tmp = X{iRegion}(iRow, :);
        if rand(1) > 0.5
            tmp = circshift(tmp, 1);
        end
        tmp_region(iRow, :) = tmp;
    end
    X_sh{iRegion} = tmp_region;
end

n_boot = 10000;
F_store = nan(1, n_boot);
for iBoot = 1:n_boot
    [p, table] = anova_rm({datasample(X_sh{1}, size(X_sh{1}, 1), 'replace', true), ...
        datasample(X_sh{2}, size(X_sh{2}, 1), 'replace', true), ...
        datasample(X_sh{3}, size(X_sh{3}, 1), 'replace', true)}, 'off');
    F_store(iBoot) = table{2, 5};
end

p = sum(F_store > F_obs) / n_boot;
