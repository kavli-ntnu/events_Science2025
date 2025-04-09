
function [sCell,N,dpthSrt,unitIDs,shankNums,chanX,chanY,meanSpikeAmp] = units(d,probeNum,shanks,posT,frCutoffs,dpthCutoffs,phyGroups,idList,posT_c)

if exist('idList','var') && isempty(idList)
    clear idList
end

minTime = posT(1);
Fs = mode(diff(posT));
maxTime = max(posT) + Fs;

sCell = cell(1);
unitIDs = cell(1,numel(d.probes(probeNum).units));
phyGroup = cell(1,numel(d.probes(probeNum).units));
for i = 1:numel(d.probes(probeNum).units)
    if exist('posT_c', 'var') && ~isempty(posT_c{1})
        tmp_spikes = [];
        for j = 1:length(posT_c)
            tmp = d.probes(probeNum).units(i).spikeTimes;
            tmp = tmp(tmp > min(posT_c{j}) & tmp < max(posT_c{j}));
            if length(tmp)
                tmp_spikes = [tmp_spikes; tmp];
            end
        end
        sCell{i} = tmp_spikes;
    else
        sCell{i} = d.probes(probeNum).units(i).spikeTimes( ...
            d.probes(probeNum).units(i).spikeTimes > minTime & ...
            d.probes(probeNum).units(i).spikeTimes < maxTime ...
            );
    end
    unitIDs{i} = d.probes(probeNum).units(i).id;
    phyGroup{i} = d.probes(probeNum).units(i).group;
    meanSpikeAmp(i) = d.probes(probeNum).units(i).meanSpikeAmplitude;
end

% check that clusters.mat file is not out of date because it used to only include 'good' units
DateString = '2021.02.05';
formatIn = 'yyyy.mm.dd';
change_date = datetime(datevec(DateString,formatIn));
finfo = dir(fullfile(d.probes(probeNum).ksdir.name, 'clusters.mat'));
file_date = datetime(datevec(finfo.date));
if (file_date - change_date) < 0
    warndlg('Clusters.mat file is out of date! Use runPostKsTasks to create a new one.')
end

% get channel and depth info
chmap = load(fullfile(d.probes(probeNum).ksdir.name, 'channelMap.mat'));
inds = [1:numel(chmap.connected)]';
inds(~chmap.connected) = 0;
maxCh = [d.probes(probeNum).units.maxAmplitudeChannel];
trueNums = inds(maxCh);
dpth = [d.probes(probeNum).units.depth];
[~,~,shankNums] = histcounts(chmap.xcoords(trueNums),-200:300:1000); % this just converts to shank number
chanX = chmap.xcoords(trueNums);
chanY = chmap.ycoords(trueNums);

% get matched IDs in the same order and quit
if exist('idList','var')
    keep = zeros(1, numel(idList)) - 1;
    for i = 1:numel(keep)
        tmp = find(strcmp(string(unitIDs), idList{i}), 1);
        if ~isempty(tmp)
            keep(i) = tmp;
        end
    end

    dpthSrt = dpth(keep);
    sCell = sCell(keep);
    unitIDs = unitIDs(keep);
    meanSpikeAmp = meanSpikeAmp(keep);
    shankNums = shankNums(keep);
    chanX = chanX(keep);
    chanY = chanY(keep);
    N = numel(sCell);
    return
end

% filter for shank num, mean rate, phyGroups, ISI, and depth
keep = ismember(shankNums,shanks);
mr = cellfun(@numel, sCell) / range(posT);
keep = keep & (mr > frCutoffs(1) & mr < frCutoffs(2))';
if exist('phyGroups', 'var')
    if ~strcmpi(phyGroups, 'all')
        keepPhy = (ismember(phyGroup, phyGroups))';
        keep = keep & keepPhy;
    end
end
ISI = cellfun(@(x) sum(diff(x) < 0.002) / numel(x), sCell);
keep = keep & (ISI' < 0.02);
keep = keep & (dpth' >= dpthCutoffs(1)) & (dpth' <= dpthCutoffs(2));

dpth = dpth(keep);
sCell = sCell(keep);
unitIDs = unitIDs(keep);
meanSpikeAmp = meanSpikeAmp(keep);
trueNums = trueNums(keep);
shankNums = shankNums(keep);
chanX = chanX(keep);
chanY = chanY(keep);

% sort by depth
[dpthSrt, indSrt] = sort(dpth);
sCell = sCell(indSrt);
unitIDs = unitIDs(indSrt);
meanSpikeAmp = meanSpikeAmp(indSrt);
shankNums = shankNums(indSrt);
chanX = chanX(indSrt);
chanY = chanY(indSrt);

% throw away cells without depth info
keep = ~isnan(dpthSrt);
dpthSrt = dpthSrt(keep);
sCell = sCell(keep);
unitIDs = unitIDs(keep);
meanSpikeAmp = meanSpikeAmp(keep);
shankNums = shankNums(keep);
chanX = chanX(keep);
chanY = chanY(keep);
N = numel(sCell);