
% Compute theta index from LFP.
%
%   USAGE
%       thetaInd = calc.thetaIndexLFP(folder,tetrode)
%       folder         directory of recording session
%       tetrode        tetrode number
%       
%   OUTPUT
%       thetaInd        ratio of theta-band (5-11 Hz) power to broadband (0-50 Hz) power
%
%   SEE ALSO
%       calc.thetaIndex
%
% Written by BRK 2016

function thetaInd = thetaIndexLFP(folder,tetrode)

%% check inputs
if (helpers.isstring(folder) + helpers.isiscalar(tetrode)) < 2
    error('Incorrect input format (type ''help <a href="matlab:help thetaIndexLFP">thetaIndexLFP</a>'' for details).');
end

%% get data
CSCfiles = dir(fullfile(folder,'*.ncs'));
if length(CSCfiles) == 0
    thetaInd = nan;
    return
elseif length(CSCfiles) == 4
    CSCind = tetrode;
else
    CSCind = tetrode * 4 - 3;
end
filename = fullfile(folder,CSCfiles(CSCind).name);
               
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

%% resample
srate0 = SampleFrequency(1);
rsrate = 500;
resampled = resample(squeezedSamples,rsrate,srate0);

%% FFT
nData = 2000000;
nHz = floor(nData/2)+1;
sineX = fft(resampled,nData)/nData;
hz = linspace(0.1,rsrate/2,nHz);
tb = dsearchn(hz',[5 11]');
bb = dsearchn(hz',[0 50]');
% db = dsearchn(hz',[1 4]');
Power = 2*abs(sineX(1:length(hz)));
% plot(hz,Power)
% xlim([0 20])

%% theta index
peakTheta = nanmax(Power(tb(1):tb(2)));
[~,peakThetaInd] = nanmin(abs(Power-peakTheta));
length1Hz = round(nHz/(rsrate/2));
thetaPower = nanmean(Power(peakThetaInd-length1Hz:peakThetaInd+length1Hz));
bbPower = nanmean(Power(bb(1):bb(2)));
% dbPower = nanmean(Power(db(1):db(2)));
thetaInd = thetaPower/bbPower;
% thetaDelta = thetaPower/dbPower;

