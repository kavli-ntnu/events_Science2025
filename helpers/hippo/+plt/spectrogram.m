
% Calculate and plot power spectrogram over time for one CSC channel.
%
%   USAGE
%       plt.spectrogram(<smoothing>)
%
%       smoothing      (optional) vertical and horizontal standard deviations [Sv Sh]
%                       for Gaussian kernel, measured in number of samples
%                       (0 = no smoothing, default = [5,0])
%
% Written by BRK 2016

function spectrogram(smoothing)

%% check input
if ~exist('smoothing','var')
    smoothing = [5,0];
end
if ~isnumeric(smoothing) || numel(smoothing) > 2
    error('Smoothing parameter must be 1 or 2 element numeric array.')
end

%% select CSC channel and clean data
[name folder] = uigetfile('*.ncs','Select LFP channel to analyze');
filename = fullfile(folder,name);
[SampleFrequency,Samples,Header] = io.neuralynx.Nlx2MatCSC(filename,[0 0 1 0 1],1,1);
squeezedSamples = reshape(Samples,512*size(Samples,2),1);
for iRow = 1:length(Header)
    if ~isempty(strfind(Header{iRow},'ADBitVolts'))
        idx = iRow;
    end
end
[~,str] =strtok(Header{idx});
scale = 1000000*str2num(str);
squeezedSamples = squeezedSamples * scale;
srate0 = SampleFrequency(1);
rsrate = 1000;
resampled = resample(squeezedSamples,rsrate,srate0);
dt = detrend(resampled);
% dt1 = walkFilter(folder,dt1,rsrate);

%% spectrogram
movingWin = [1 0.1];
params.Fs = 1000;
params.fpass = [0 250];
params.tapers = [3 5]; % defalt values
params.pad = 2;
params.trialave = 1;
params.err = 0;

[specPower,specTime,specFreq] = mtspecgramc(dt,movingWin,params);

%% plot
figure;
plot_matrix(general.smooth(specPower,smoothing),specTime,specFreq);
set(gca,'fontsize',14)
p = get(gcf,'position');
set(gcf,'position',p + [0 0 900 0])
xlabel 'Time (sec)'
ylabel 'Frequency (Hz)'
title ''
h = colorbar; h.Label.String = '10*log10(Power)'; h.Label.FontSize = 14;
ylim([0 30])
caxis([10 45]);

%% display power in different frequency bands
bandNames = {'Delta','Theta','Beta','Low gamma','High gamma','Ripple'};
bands = [4 6; 6 12; 20 30; 30 55; 61 100; 110 250];

bandMeans = nan(1,size(bands,1));
for iBand = 1:size(bands,1)
    freqRangeInds = specFreq > bands(iBand,1) & specFreq < bands(iBand,2);
    bandMeans(1,iBand) = mean(nanmean(specPower(:,freqRangeInds),2));
    display(sprintf('%s:      %.2f',bandNames{iBand},bandMeans(iBand)))
end

end

function samples = walkFilter(folder,samples,rsrate)
global hippoGlobe

xVals = linspace(0,length(samples)/rsrate,length(samples));
writeInputBNT(hippoGlobe.inputFile,folder,hippoGlobe.arena,hippoGlobe.clusterFormat)
data.loadSessions(hippoGlobe.inputFile)
posAve = data.getPositions('speedFilter',[0 2]);
xVals2 = linspace(0,length(posAve)/25,length(posAve));
toRemove = isnan(posAve(:,2));
samples(knnsearch(xVals',xVals2(toRemove)')) = [];

end