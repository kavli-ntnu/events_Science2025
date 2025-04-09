

function [decodeError, decodeError_sh] = seq_mill_decoding

ds = dir('N:\benjamka\events\data\sequence\decoding');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds_mill = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'_mill_'}, 1, length(names)), 'uniformoutput', false)));
names = names(inds_mill);

decodeError = [];
decodeError_sh = [];
for i = 1:length(names)
    load(fullfile(ds(1).folder, names{i}))
    if isempty(strfind(names{i}, '_sh'))
        decodeError = [decodeError, nanmean(decode_error(:))];
    else
        decodeError_sh = [decodeError_sh, nanmean(decode_error(:))];
    end
end

figure, hold on

COLOR = 'k';
plot(1:2, [decodeError; decodeError_sh], '-', 'color', COLOR, 'linew', 1)
plot(1:2, [nanmean(decodeError), nanmean(decodeError_sh)] , 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
err1 = nanstd(decodeError) / sqrt(sum(~isnan(decodeError)));
err2 = nanstd(decodeError_sh) / sqrt(sum(~isnan(decodeError_sh)));
errorbar(1:2, [nanmean(decodeError), nanmean(decodeError_sh)],[err1, err2] , 'color', COLOR, 'linew', 2)

load figp
fixPlot(1:2, {'Actual', 'Shuffle'}, '', 'Decoding error (sec)')
xlim([0.5, 2.5])
figp_skinny = figp;
figp_skinny(3) = figp_skinny(3) / 2;
set(gcf,'pos',figp_skinny), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 30)
