
function [tSWS tREM lfp] = splitSleep(d,folder,probeNum,seshInd,chNum,thrTDRlo,thrTDRhi)

if ~exist('thrTDRlo', 'var')
    thrTDRlo = 0.8;
    thrTDRhi = 1.0;
end

pos.x = d.tracking.x;
pos.y = d.tracking.y;
pos.hd = d.tracking.hd_azimuth;
pos.fs = round(1 / mode(diff(d.tracking.t)));

chNum = num2str(chNum);
switch numel(chNum)
    case 1
        chNum = ['00',chNum];
    case 2
        chNum = ['0',chNum];
end
fid = fopen(fullfile(folder,sprintf('probe_%d',probeNum),'npx.imec.lf.bin.channels',[chNum,'.dat']));
if fid == -1
    fid = fopen(fullfile(folder,sprintf('probe_%d',probeNum),'npx.imec.ap.bin.channels',[chNum,'.dat']));
end

lf = fread(fid,inf,'int16');
fclose(fid);
% resample for speed
dt_lfp0 = 1/2500;
dt_lfp = 1/500;
lf = resample(lf,1,dt_lfp/dt_lfp0);

lfp.fs = 1/dt_lfp;
lfp.t = linspace(dt_lfp,dt_lfp*numel(lf),numel(lf));
lfp.y = lf;
pos.t = d.tracking.t;

[epochStartTime, epochStopTime] = npx_banal.getEpochTimes(d,seshInd);
[tSWS tREM] = rg.lfp.detectSleep(pos, lfp, [epochStartTime epochStopTime],'thrTDRlo',thrTDRlo,'thrTDRhi',thrTDRhi,'plot',true);

inds = lfp.t > epochStartTime & lfp.t < epochStopTime;
lfp.t = lfp.t(inds);
lfp.y = lfp.y(inds);

% SWSind = 3; % this matches the decoding
% nSm = round(2 * lfp.fs);
% [b,a] = butter(2, [5 10] / (lfp.fs/2));
% tmp = filtfilt(b, a, lfp.y(lfp.t > tREM(REMind,1) & lfp.t < tREM(REMind,2)));
% thetaAmp = general.smooth(abs(hilbert(tmp)),nSm);