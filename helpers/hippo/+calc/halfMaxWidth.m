
% Calculate width at the half maximum of a waveform.
%
%   USAGE
%       spikeWidth = calc.halfMaxWidth(userDir,tetrode,spikes)
%       userDir        directory of recording session
%       tetrode        tetrode number
%       spikes         list of spike timestamps
%
%   OUTPUT
%       spikeWidth     width at half max
%
%   SEE ALSO
%       penguin meta.emperorPenguin
%
% Written by BRK 2014

function spikeWidth = halfMaxWidth(userDir,tetrode,spikes)

%% fix me
global hippoGlobe
if strcmpi(hippoGlobe.clusterFormat,'Tint')
    spikeWidth = nan;
    return
end

%% check inputs
if (helpers.isstring(userDir) + helpers.isiscalar(tetrode) + helpers.isdvector(spikes)) < 3
    error('Incorrect input format (type ''help <a href="matlab:help halfMaxWidth">halfMaxWidth</a>'' for details).');
end

%% load data
nttFiles = dir(fullfile(userDir,'*.ntt'));
for iTrode = 1:length(nttFiles)
    found = regexp(nttFiles(iTrode).name,sprintf('TT%d',tetrode),'once');
    if ~isempty(found)
        ind = iTrode;
    end
end
spikeFile = [userDir,'\',nttFiles(ind).name];
[trodeTS,trodeData] = io.neuralynx.Nlx2MatSpike(spikeFile,[1,0,0,0,1],0,1);     % open Nlx2MatSpike for help with arguments
trodeTS_sec = (trodeTS/1000000)';
clusterTS = spikes;
clusterData = trodeData(:,:,knnsearch(trodeTS_sec,clusterTS));
clusterData = clusterData/100;        % convert to microvolts

%% peak alignment and averaging
meanWave = zeros(32,4);
for iChannel = 1:4
    voltages = squeeze(clusterData(:,iChannel,:));
    % trick to find max for each wave in matrix
    idx = find(voltages==repmat(max(voltages,[],1),32,1));
    [r,c] = ind2sub(size(voltages),idx);
    peakInds = accumarray(c,r,[],@min);
    shiftAmount = 8 - peakInds;
    % trick for circshift using different shift amounts for each wave
    [r,c] = size(voltages);
    temp = mod(bsxfun(@plus,(0:r-1).',-shiftAmount(:).' ),r)+1;
    temp = bsxfun(@plus,temp,(0:c-1)*r);
    alignedVoltages = voltages(temp);
    % cutoff tail (can we vectorize this??)
    for iWave = 1:length(clusterTS)
        v = alignedVoltages(:,iWave);
        if shiftAmount(iWave) < 0
            v(end-abs(shiftAmount(iWave)):end) = nan;
            alignedVoltages(:,iWave) = v;
        end
    end
    meanWave(:,iChannel) = nanmean(alignedVoltages,2);
    peaks(iChannel) = max(max(meanWave(:,iChannel)));
end

%% select dominant channel
[maxPeak, maxPeakIdx] = max(peaks);
halfMax = maxPeak / 2;

%% interpolate
interpWave = interp1(1:32,meanWave(:,maxPeakIdx),1:0.01:32,'spline');
interpMaxIdx = find(interpWave == maxPeak);
Diff = sort(abs(halfMax - interpWave(1:interpMaxIdx))); 
Diff2 = sort(abs(halfMax - interpWave(interpMaxIdx+1:end)));
closest = find(abs(halfMax - interpWave) == Diff(1));
closest2 = find(abs(halfMax - interpWave) == Diff2(1));
spikeWidth = abs(closest - closest2) * (1/3101) * 1000;

