
% Calculate and plot power spectrum over time for one animal. Used mainly
% to check for theta power in the LFP during screening.
%
%   USAGE
%       plt.powerSpectrum(<CSCnums>,<numSesh>)
%       CSCnums         (optional) vector specifying which CSC numbers to
%                       analyze (default = 1:4)
%       numSesh         (optional) double specifying number of sessions to
%                       analyze (default = 10)
%
%   NOTES
%       This function works by searching directories for your mouse ID and may fail
%       if the directory structure or naming scheme is not as expected. See section
%       'check mouse names' below for more info.
%
% Written by BRK 2015

function powerSpectrum(CSCnums,numSesh)

%% choose directory and CSC files
userDir = uigetdir();
if ~exist('CSCnums','var') || isempty(CSCnums)
    CSCnums = 1:4;
end
if ~exist('numSesh','var')
    numSesh = 10;
end

%% find directory names
splits = regexp(userDir,'\','split');
filePath0 = fullfile(splits{1:end-1});
myDir = dir(filePath0);
names = extractfield(myDir,'name');

h = msgbox('Working ...');

%% check mouse names
if ~isempty(strfind(userDir,'BK'))
    ind = strfind(userDir,'BK');
    if length(ind) > 1; ind = ind(end); end;
    mouseName = userDir(ind:ind+4);
elseif ~isempty(strfind(userDir,'CML'))
    ind = strfind(userDir,'CML');
    if length(ind) > 1; ind = ind(end); end;
    mouseName = userDir(ind:ind+5);
elseif ~isempty(strfind(userDir,'KA'))
    ind = strfind(userDir,'KA');
    if length(ind) > 1; ind = ind(end); end;
    mouseName = userDir(ind:end);
elseif ~isempty(strfind(userDir,'rat'))
    ind = strfind(userDir,'rat');
    if length(ind) > 1; ind = ind(end); end;
    mouseName = userDir(ind+3:end);
else
    prompt={'Mouse name'};
    name='Did not recognize mouse naming scheme';
    numlines=1;
    defaultanswer={'BK'};
    mouseName = inputdlg(prompt,name,numlines,defaultanswer,'on');
    if isempty(mouseName); return; end;
    mouseName = mouseName{1};
end

%% find all session names and show 10 most recent
seshCount = 0;
for iFolder = 1:length(names)
    ind = strfind(names{iFolder},mouseName);
    if ~isempty(ind)
        seshCount = seshCount + 1;
        nameStore{seshCount} = names{iFolder};
    end
end
if seshCount > numSesh
    nameStore = nameStore(end-(numSesh-1):end);
    seshCount = numSesh;
    fprintf('Only showing %d most recent sessions ...\n',numSesh)
elseif ~seshCount
    error('Did not find any directories matching mouse name: %s',mouseName)
end

%% initialize
nData = 2000000;
nHz = floor(nData/2)+1;
nPower = 1000001;
h1 = figure;
set(gcf,'name',mouseName)
h2 = figure;
set(gcf,'name',mouseName)

%% do it
plotSize = ceil(sqrt(numel(CSCnums)));
for iCSC = CSCnums
    power = nan(seshCount,nPower);
    for iSession = 1:seshCount
        % get data and clean up
        fileEnding = sprintf('CSC%d.ncs',iCSC);
        filename = fullfile(splits{1:end-1},nameStore{iSession},fileEnding);
        try
            [SampleFrequency,Samples,Header] = io.neuralynx.Nlx2MatCSC(filename,[0 0 1 0 1],1,1);
        catch
            warning('CSC loading failed. Check that selected CSC files actually exist')
            continue
        end
        squeezedSamples = reshape(Samples,512*size(Samples,2),1);
        for iRow = 1:length(Header)
            if ~isempty(strfind(Header{iRow},'ADBitVolts'))
                idx = iRow;
            end
        end
        [~,str] =strtok(Header{idx});
        scale = 1000000*str2double(str);
        squeezedSamples = squeezedSamples * scale;
        srate0 = SampleFrequency(1);
        rsrate = 500;
        try
            resampled = resample(squeezedSamples,rsrate,srate0);
        catch
            continue
        end
        ds = detrend(resampled);
        
        % FFT
        sineX = fft(ds,nData)/nData;
        hz = linspace(0.1,rsrate/2,nHz);
        hzBounds = dsearchn(hz',[1 15]');
        tempPower = 2*abs(sineX(1:length(hz)));
        Power = tempPower;
        tempPower = tempPower/max(tempPower);
        tempPower = general.smooth(tempPower,10);
        power(iSession,:) = tempPower;
        
        % theta index
        tb = dsearchn(hz',[5 11]');
        bb = dsearchn(hz',[0.5 50]');
        peakTheta = nanmax(Power(tb(1):tb(2)));
        [~,peakThetaInd] = min(abs(Power-peakTheta));
        length1Hz = round(nHz/(rsrate/2));
        thetaPower = nanmean(Power(peakThetaInd-length1Hz:peakThetaInd+length1Hz));
        bbPower = nanmean(Power(bb(1):bb(2)));
%         fprintf('Current session theta index = %.2f\n',thetaPower/bbPower)
        thetaInd(iSession,iCSC) = thetaPower/bbPower;
    end
    
    %% heat maps for each recording session for each LFP channel
    figure(h1)
    subplot(plotSize,plotSize,find(CSCnums == iCSC))
    imagesc(hz(hzBounds(1):hzBounds(2)),1:seshCount,power(:,hzBounds(1):hzBounds(2)))
    xlabel('Frequency'), ylabel('Session')
    title(fileEnding(1:end-4))
    
    %% line graphs for each recording session for each LFP channel
    % N.B. most recent session plotted on top
    figure(h2);
    subplot(plotSize,plotSize,find(CSCnums == iCSC))
    cmap = colormap('jet');
    cmap = cmap(round(linspace(1,length(cmap),seshCount)),:);
    set(gca,'colororder',cmap,'NextPlot','replacechildren')
    plot(hz(hzBounds(1):hzBounds(2)),power(:,hzBounds(1):hzBounds(2)))
    axis([1 15 0 nanmax(nanmax(power(:,hzBounds(1):hzBounds(2))))])
    xlabel('Frequency'), ylabel('Power')
    title(fileEnding(1:end-4))

end

close(h);

thetaInd(:,all(thetaInd == 0)) = [];
try
    thetaInd(all(thetaInd == 0,1)) = [];
end

fprintf(' --- Theta indices --- \n')
disp(thetaInd)

