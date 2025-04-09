
function total_dist = calculate_pv_distance(smat_n, epochs)

score = smat_n';
tmp1 = squeeze(score(epochs == min(epochs), :));
tmp2 = squeeze(score(epochs == max(epochs), :));
stop_ind = size(tmp1, 1);
dists_allD = squareform(pdist(vertcat(tmp1, tmp2),'cosine'));
dists_endpt = dists_allD(1:stop_ind, stop_ind+1:end);
total_dist = nanmean(dists_endpt(:));

end