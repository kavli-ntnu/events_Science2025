

function decode_error_all = decoding_error(regions, colors)

figure, hold on

for iRegion = 1:length(regions)

    decode_error_pool = [];
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\decodeErrorFull_%s_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            decode_error = tmp.decode_error;
        else
            break
        end
        decode_error_pool = [decode_error_pool, decode_error];
    end

    % store vals
    tmp = decode_error_pool;
    decode_error_all{iRegion} = tmp(~isnan(tmp));
end

decode_error_sh_pool = [];
for iRegion = 1:length(regions)
    for iPool = 1:100
        fname = sprintf('N:\\benjamka\\events\\data\\foraging\\decodeErrorFull_%ssh_%d.mat', regions{iRegion}, iPool);
        if exist(fname, 'file')
            tmp = load(fname);
            decode_error_sh = tmp.decode_error;
        else
            break
        end
        decode_error_sh_pool = [decode_error_sh_pool, nanmean(decode_error_sh)];
    end
end
% store vals
tmp = decode_error_sh_pool;
decode_error_all{end + 1} = tmp(~isnan(tmp));

for iGroup = 1:size(colors, 1)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(decode_error_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(decode_error_all{iGroup}), nanstd(decode_error_all{iGroup}) / sqrt(sum(~isnan(decode_error_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(decode_error_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(colors, 1), [regions(1:3), 'Shuffle'], '', 'Decoding error (min)')
xlim([0.5, size(colors, 1) + 0.5])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)