
% Filter LFP in theta band and extract phase.
%
%   USAGE
%       [phs,xVals,TimeStamps] = calc.thetaPhase(filename)
%       filename       full path to CSC file
%
%   OUTPUT
%       phs            phase angle (radians)
%       xVals          timestamps at a frequency that matches the theta filtered signal
%       TimeStamps     original LFP timestamps
%
% Written by BRK 2017

function [phs,xVals,TimeStamps] = thetaPhase(filename)

%% check input
if helpers.isstring(filename) < 1
    error('Input must be a string')
end

%% load LFP
[TimeStamps,SampleFrequency,Samples,Header] = io.neuralynx.Nlx2MatCSC(filename,[1 0 1 0 1],1,1);
squeezedSamples = reshape(Samples,512*size(Samples,2),1);

% isolate 2nd half of CNO session
if ~isempty(strfind(filename,'CNO'))
    TimeStamps = TimeStamps(end-round(length(TimeStamps)/2):end);
    squeezedSamples = squeezedSamples(end-round(length(squeezedSamples)/2):end);
end
    
for iRow = 1:length(Header)
    if ~isempty(strfind(Header{iRow},'ADBitVolts'))
        idx = iRow;
    end
end
[~,str] =strtok(Header{idx});
scale = 1000000*str2double(str);
squeezedSamples = squeezedSamples * scale;
srate0 = SampleFrequency(1);

%% downsample to save time
rsrate = 1000;
resampled = resample(squeezedSamples,rsrate,srate0);

%% theta filter
[b a] = butter(2, [4/(rsrate/2) 12/(rsrate/2)], 'bandpass');
filt_theta = filter(b,a,resampled);
xVals = linspace(0,range(TimeStamps),length(filt_theta))';  

%% extract phase
phs = unwrap(angle(hilbert(filt_theta)));
phs = mod(phs,2*pi);
