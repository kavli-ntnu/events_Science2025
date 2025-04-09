

function decodeError_all = seq_trial_number_decoding(regions, colors)

ds = dir('N:\benjamka\events\data\sequence\decoding');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'decodeError_trial'}, 1, length(names)), 'uniformoutput', false)));
names = names(inds);

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

decodeError_all{1} = decodeError;
decodeError_all{4} = decodeError_sh;

%

ds = dir('N:\benjamka\events\data\sequence\MEC\decoding');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'decodeError_trial'}, 1, length(names)), 'uniformoutput', false)));
names = names(inds);

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

decodeError_all{2} = decodeError;

%

ds = dir('N:\benjamka\events\data\sequence\CA1\decoding');
clear names
for i = 3:length(ds)
    names{i-2} = ds(i).name;
end
inds = ~cellfun(@isempty, (cellfun(@strfind, names, repmat({'decodeError_trial'}, 1, length(names)), 'uniformoutput', false)));
names = names(inds);

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

decodeError_all{3} = decodeError;

figure, hold on
for iGroup = 1:size(colors, 1)
    COLOR = colors(iGroup, :);
    plot(iGroup, nanmean(decodeError_all{iGroup}), 'o', 'color', COLOR, 'linew', 5, 'markersize', 15)
    errorbar(iGroup, nanmean(decodeError_all{iGroup}), nanstd(decodeError_all{iGroup}) / sqrt(sum(~isnan(decodeError_all{iGroup}))), 'color', COLOR, 'linew', 2)
    plotSpread(decodeError_all(iGroup), 'xvalues', iGroup, 'distributionColors', COLOR)
end

set(findobj(gca, 'type', 'line', '-not', 'marker', 'o'), 'markers', 20)

load figp
fixPlot(1:size(colors, 1), [regions(1:3), 'Shuffle'], '', 'Decoding error (# of trials)')
xlim([0.5, size(colors, 1) + 0.5])
ylim([0 6])
set(gcf,'pos',figp), movegui
set(gca,'fontsize', 24)
rotateXLabels(gca, 0)
