
% Plot broadband LFP trace(s). If multiple channels are selected, they are plotted in the same figure window.
%
%   USAGE
%       plt.LFP
%
%   NOTES
%       Multiple traces are plotted with their voltages offset so that they can be
%       visualized in the same figure window.
%
%   SEE ALSO
%       plt.LFPfilter
%
% Written by BRK 2017

function LFP

%% select trace(s)
[name,path] = uigetfile('*.ncs','Select CSC file(s)','multiselect','on');
if iscell(name)
    numTraces = length(name);
else
    numTraces = 1;
end

%% prepare figure and colors
figure('position',[9 583 1900 494],'name',path)

% allow quick switching between x limits
uicontrol(gcf,'style','togglebutton', ...
    'string','<html>Change x range<br>to 5 sec', ...
    'units','normalized','position',[0.925 0.01 0.07 0.2], ...
    'enable','inactive', ...
    'buttondownfcn',@updateXlim);

hold on
xlabel 'Time (sec)'
ylabel 'Voltage (uV)'
cmap = parula(64);
cmap = cmap(round(linspace(1,50,numTraces)),:);

try % animal speed colorbar
    global hippoGlobe
    writeInputBNT(hippoGlobe.inputFile,path,hippoGlobe.arena,hippoGlobe.clusterFormat)
    data.loadSessions(hippoGlobe.inputFile)
    pos = data.getPositions();
    s = general.speed(pos);
    s(isnan(s)) = 0;
    if hippoGlobe.posSpeedFilter(1) > 0 && hippoGlobe.posSpeedFilter(1) <= 5
        [~,~,s] = histcounts(s,[0 hippoGlobe.posSpeedFilter(1) 5 10 15 20 25 30 inf]);
        speedLabels = {sprintf('Below %d',hippoGlobe.posSpeedFilter(1)), ...
                    sprintf('%d - 5',hippoGlobe.posSpeedFilter(1)), ...
                    '5 - 10','10 - 15','15 - 20','20 - 25','25 - 30','30+'};
    elseif hippoGlobe.posSpeedFilter(1) > 5 && hippoGlobe.posSpeedFilter(1) <= 10
        [~,~,s] = histcounts(s,[0 hippoGlobe.posSpeedFilter(1) 10 15 20 25 30 inf]);
        speedLabels = {sprintf('Below %d',hippoGlobe.posSpeedFilter(1)), ...
                    sprintf('%d - 10',hippoGlobe.posSpeedFilter(1)), ...
                    '10 - 15','15 - 20','20 - 25','25 - 30','30+'};
    end
    
end

%% load trace(s)
for iTrace = 1:numTraces
    
    if numTraces > 1
        filename = fullfile(path,name{iTrace});
    else
        filename = fullfile(path,name);
    end
    
    fprintf('Loading trace %d of %d...\n',iTrace,numTraces)
    [SampleFrequency,Samples,Header] = io.neuralynx.Nlx2MatCSC(filename,[0 0 1 0 1],1,1);
    squeezedSamples = reshape(Samples,512*size(Samples,2),1);
    
    % scale to microvolts
    if iTrace == 1
        for iRow = 1:length(Header)
            if ~isempty(strfind(Header{iRow},'ADBitVolts'))
                idx = iRow;
            end
        end
        [~,str] = strtok(Header{idx});
        scale = 1000000*str2num(str);
    end
    squeezedSamples = squeezedSamples * scale;
    
    % downsample to save time
    srate0 = SampleFrequency(1);
    rsrate = 1000;   % 1 kHz
    resampled = resample(squeezedSamples,rsrate,srate0);
    
    % detrend to correct DC shifts
    dt_resampled = detrend(resampled);
    
    %% plot broadband signal
    if iTrace == 1
        xVals = linspace(0,length(dt_resampled)/rsrate,length(dt_resampled));   % convert to secs
%         offset = std(dt_resampled)*5;
        offset = 2000;
        try % animal speed colorbar
            speedX = linspace(0,length(s)/25,length(s));   % convert to secs
            cmapSpeed = jet(numel(speedLabels));
            cmapSpeed(1,:) = 0;
            plt.hotLine(speedX,zeros(1,length(speedX))+offset,zeros(1,length(speedX)),s,8,cmapSpeed)
            caxis([1 numel(speedLabels)])
            colorbar('TickLabels',speedLabels,'FontWeight','bold');
        end
        if numTraces > 1
            plot(xVals,dt_resampled,'color',cmap(iTrace,:))
        else
            plot(xVals,dt_resampled,'k')
        end
    else
        try
            plot(xVals,dt_resampled - (offset * (iTrace-1)),'color',cmap(iTrace,:))
        end
    end
    drawnow
    
end

%% legend
[~,icons] = legend(flipud(findobj(gca,'type','line')),name,'location','eastoutside','box','off');
set(findobj(icons,'type','line'),'linew',3)

disp('Done.')
keyboardnavigate   % this lets you scroll with the arrow keys (when not in zoom/pan/edit modes)


%% nested function for updating x axis limits
function updateXlim(~,eventData)

if strcmpi(eventData.Source.String,'<html>Change x range<br>to full session')
    xlim auto
    eventData.Source.String = '<html>Change x range<br>to 5 sec';
else
    xlim([0 5])
    eventData.Source.String = '<html>Change x range<br>to full session';
end

