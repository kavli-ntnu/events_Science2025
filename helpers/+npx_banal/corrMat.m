
function corr_mat = corrMat(smat, full)

if nargin < 2
    full = false;
end

corr_mat = nan(size(smat, 2), size(smat, 2));
for i = 1:size(smat, 2)
    for j = 1:size(smat, 2)
        if ~full
            if j <= i
                corr_mat(i, j) = corr(smat(:, i), smat(:, j), 'rows', 'pairwise');
            end
        else
            corr_mat(i, j) = corr(smat(:, i), smat(:, j), 'rows', 'pairwise');
        end
    end
end