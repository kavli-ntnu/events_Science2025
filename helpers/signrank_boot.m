
function p = signrank_boot(X)

X = X(:);

rng(666)
boot_means = [];
obs_mean = nanmean(X);
for i = 1:10000
    boot_means(i) = mean(datasample(X, numel(X), 'replace', true)) - obs_mean;
end
p = sum(abs(boot_means) > abs(obs_mean)) / 10000;