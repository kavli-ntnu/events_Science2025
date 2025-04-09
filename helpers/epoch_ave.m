function smat_epoch_ave = epoch_ave(smat_n, epochs)

N_epochs = length(unique(epochs));
smat_epoch_ave = nan(size(smat_n, 1), N_epochs);
for i = 1:N_epochs
    smat_epoch_ave(:, i) = mean(smat_n(:, epochs == i), 2);
end