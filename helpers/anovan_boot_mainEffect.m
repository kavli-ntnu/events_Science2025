
function p = anovan_boot_mainEffect(X)

% NB: assumes 3 groups and 2 timepoints per group

y_bn = vertcat(X{1}, X{2}, X{3});
y_bn = y_bn(:);
grp1_bn = [ones(1, size(X{1}, 1)), ones(1, size(X{2}, 1)) + 1, ones(1, size(X{3}, 1)) + 2]';
grp1_bn = vertcat(grp1_bn, grp1_bn);
grp2_bn = [ones(1, length(grp1_bn) / 2), ones(1, length(grp1_bn) / 2) + 1]';
[p, table] = anovan(y_bn, {grp1_bn, grp2_bn})
F_obs = table{3, 6};

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
    
    y_bn = vertcat(datasample(X_sh{1}, size(X_sh{1}, 1), 'replace', true), ...
        datasample(X_sh{2}, size(X_sh{2}, 1), 'replace', true), ...
        datasample(X_sh{3}, size(X_sh{3}, 1), 'replace', true));
    y_bn = y_bn(:);

    [p, table] = anovan(y_bn, {grp1_bn, grp2_bn}, 'display', false);
    F_store(iBoot) = table{3, 6};
end

p = sum(F_store > F_obs) / n_boot;