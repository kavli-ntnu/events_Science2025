
% Plot broadband LFP trace, optionally adding theta- and ripple-band filtered traces.
%
%   USAGE
%       plt.LFPfilter(<options>)
%       <options>       'theta' and/or 'ripple' will add these filtered traces
%
%   NOTES
%       Theta- and ripple-band traces are plotted with their voltages offset so that they can be
%       visualized in the same figure window.
%
%   SEE ALSO
%       plt.LFP
%
% Written by BRK 2017

function LFPfilter(varargin)

%% check inputs
for iArg = 1:length(varargin)
   if ~helpers.isstring(varargin{iArg},'theta','ripple') 
       error('Expected input arguments ''theta'' and/or ''ripple''')
   end
end

%% select and load LFP
[name,path] = uigetfile('*.ncs','Select CSC file');
filename = fullfile(path,name);

disp('Loading CSC file...')
[Timestamps,SampleFrequency,Samples,Header] = io.neuralynx.Nlx2MatCSC(filename,[1 0 1 0 1],1,1);
squeezedSamples = reshape(Samples,512*size(Samples,2),1);   

% scale to microvolts
disp('Scaling voltages...')
for iRow = 1:length(Header)
    if ~isempty(strfind(Header{iRow},'ADBitVolts'))
        idx = iRow;
    end
end
[~,str] = strtok(Header{idx});
scale = 1000000*str2double(str);
squeezedSamples = squeezedSamples * scale;

% downsample to save time
disp('Resampling and detrending...')
srate0 = SampleFrequency(1);
rsrate = 1000;   % 1 kHz
resampled = resample(squeezedSamples,rsrate,srate0);

% detrend to correct DC shifts
dt_resampled = detrend(resampled);

%% plot broadband signal
xVals = linspace(0,length(dt_resampled)/rsrate,length(dt_resampled));   % convert to secs

figure('position',[9 860 1900 217],'name',filename)
hold on
plot(xVals,dt_resampled,'k')
xlabel 'Time (sec)'
ylabel 'Voltage (uV)'

try % animal speed colorbar
    global hippoGlobe
    writeInputBNT(hippoGlobe.inputFile,path,hippoGlobe.arena,hippoGlobe.clusterFormat)
    data.loadSessions(hippoGlobe.inputFile)
    pos = data.getPositions();
    s = general.speed(pos);
    s(isnan(s)) = inf; % NaNs are not good ripple times
    [~,~,s] = histcounts(s,[0 hippoGlobe.posSpeedFilter(1) inf]);
    speedLabels = {sprintf('Below %d',hippoGlobe.posSpeedFilter(1)), ...
        sprintf('%d+',hippoGlobe.posSpeedFilter(1))};
end

% allow quick switching between x limits
uicontrol(gcf,'style','togglebutton', ...
    'string','<html>Change x range<br>to 5 sec', ...
    'units','normalized','position',[0.925 0.01 0.07 0.2], ...
    'enable','inactive', ...
    'buttondownfcn',@updateXlim);

%% theta filter (4-12 Hz)
if sum(strcmpi('theta',varargin))
    disp('Theta filter...')
    [b a] = butter(2,[4/(rsrate/2) 12/(rsrate/2)],'bandpass');
    filt_theta = filter(b,a,dt_resampled);
%     offset = std(dt_resampled)*3;
    offset = 3000;
    plot(xVals,filt_theta - offset,'b')
    
    % resize window
    set(gcf,'position',[9 618 1900 459])
end

%% ripple filter (100-400 Hz)
if sum(strcmpi('ripple',varargin))
    disp('Ripple filter...')
    [b a] = butter(2,[100/(rsrate/2) 400/(rsrate/2)],'bandpass');
    filt_ripple = filter(b,a,dt_resampled);
    if ~exist('offset','var')
        offset = std(dt_resampled)*3;
    end
    plot(xVals,filt_ripple + offset,'r')
    
    %
%     load('G:\Ymaze\Refined\2017-10-29_08-06-24_VK121_maze_BL\2017-10-29_08-06-24_VK121_maze_BL_T1C1_4F18E1C1F7DD8BB0235E118FF7CC7AED.mat')
%     plot(cellTS-(Timestamps(1)/1000000),ones(1,length(cellTS))+1000,'b*')
    %
    
    
    try % animal speed colorbar
        speedX = linspace(0,length(s)/25,length(s));   % convert to secs
        cmapSpeed = [0 0 1; 0 0 0]; % blue is good times, black is bad times (high speed)
        plt.hotLine(speedX,zeros(1,length(speedX))+offset*2,zeros(1,length(speedX)),s,8,cmapSpeed)
        colorbar('Ticks',1:2,'TickLabels',speedLabels,'FontWeight','bold');
    end
    
    % resize window
    if sum(strcmpi('theta',varargin))
        set(gcf,'position',[9 284 1900 793])
    else
        set(gcf,'position',[9 618 1900 459])
    end
    
    % show ripple intervals
    thresh = 5;
    handles.text_rippThresh = uicontrol(gcf,'style','edit', ...
        'string',num2str(thresh), ...
        'units','normalized','position',[0.96 0.21 0.035 0.05], ...
        'callback',{@updateThresh,filt_ripple,rsrate});
    uicontrol(gcf,'style','text', ...
        'string','Threshold (std)', ...
        'units','normalized','position',[0.96 0.26 0.035 0.1]);
    uicontrol(gcf,'style','togglebutton', ...
        'string','<html>Find<br>ripples', ...
        'units','normalized','position',[0.925 0.21 0.035 0.15], ...
        'enable','inactive', ...
        'buttondownfcn',{@identifyRipples,filt_ripple,rsrate,thresh});
    
end

%% legend
if length(varargin) == 2
    [~,icons] = legend({'Broadband','Theta','Ripple'},'orientation','horizontal','location','northoutside','box','off');
elseif sum(strcmpi('theta',varargin))
    [~,icons] = legend({'Broadband','Theta'},'orientation','horizontal','location','northoutside','box','off');
elseif sum(strcmpi('ripple',varargin))
    [~,icons] = legend({'Broadband','Ripple'},'orientation','horizontal','location','northoutside','box','off');
end
if exist('icons','var')
    set(findobj(icons,'type','line'),'linew',3)
end

disp('Done.')
keyboardnavigate   % this lets you scroll with the arrow keys (when not in zoom/pan/edit modes)

try
    guidata(gcf,handles)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%      END OF MAIN FUNCTION       %%%%%%%%%%%%%%%%%%%%%%%%% %%


%% update x axis limits
function updateXlim(~,eventData)

if strcmpi(eventData.Source.String,'<html>Change x range<br>to full session')
    xlim auto
    eventData.Source.String = '<html>Change x range<br>to 5 sec';
else
    xlim([0 5])
    eventData.Source.String = '<html>Change x range<br>to full session';
end

%% find ripples
function identifyRipples(hObject,~,filt_ripple,rsrate,thresh)

handles = guidata(hObject);

filt_ripple_abs = abs(filt_ripple);
MEAN = nanmean(filt_ripple_abs);
STD = nanstd(filt_ripple_abs);
rippThresh = MEAN + (STD * thresh);
ripp_inds = find(filt_ripple_abs > rippThresh);
ripp_times = ripp_inds/rsrate;

% only keep times when there is another event within 20 msec
d = diff(ripp_times);
count = 1;
times = [];
for i = 1:length(ripp_times)-1
   if d(i) < 0.02
      times(count:count+1) = ripp_times(i:i+1);
      count = count+2;
   end
end
if ~isempty(times)
    ripp_times = unique(times);
    
    % separate into intervals
    d = diff(ripp_times) > 0.02;
    d2 = find(d == 0);
    toRemove = find(diff(d2) == 1)+1;
    startInds = find(d == 0);
    startInds(toRemove) = nan;
    startInds = startInds(~isnan(startInds));
    row = 1;
    ripp_ints = nan(length(startInds),2);
    for i = startInds
        ripp_ints(row,1) = ripp_times(i);
        intLength = find(d(i:end) == 1,1) - 1;
        if isempty(intLength)
            continue
        end
        ripp_ints(row,2) = ripp_times(i+intLength);
        row = row + 1;
    end
    
    % remove intervals shorter than 20 msec
    tooShort = (ripp_ints(:,2)-ripp_ints(:,1)) < 0.02;
    ripp_ints = ripp_ints(~tooShort,:);
    ripp_ints = ripp_ints(~any(isnan(ripp_ints),2),:);
    numRipples = size(ripp_ints,1);
else
    numRipples = 0;
end

% create slider for looking at ripples
if numRipples
    
    % delete any old info
    delete(findobj(gcf,'type','uicontrol','style','slider'));
    delete(findobj(gcf,'type','uicontrol','style','text'));
    delete(findobj(gcf,'type','line','linewidth',3));
    
    % make new slider
    uicontrol(gcf,'style','text', ...
        'string','Threshold (std)', ...
        'units','normalized','position',[0.96 0.26 0.035 0.1]);
    slide_ripp = uicontrol('style','slider', ...
        'units','normalized','position',[0.925 0.37 0.07 0.05], ...
        'value',1, ...
        'min',1,'max',numRipples,'sliderstep',[1/numRipples 10/numRipples], ...
        'callback',@updateRipple);
    
    % zoom in and plot all ripples
    xlim([ripp_ints(1,1) - 2.5, ripp_ints(1,1) + 2.5])
    for iRipp = 1:numRipples
        plot([ripp_ints(iRipp,1), ripp_ints(iRipp,2)],[MEAN+(STD*50), MEAN+(STD*50)],'r-','linew',3)      
    end
    initialStr = sprintf('%d of %d',1,numRipples);
    handles.slide_ripp = slide_ripp;
    handles.ripp_ints = ripp_ints;
    
else
    initialStr = 'No ripples detected';
end

% text showing what ripple is displayed
text_ripp = uicontrol('style','text', ...
    'units','normalized','position',[0.925 0.42 0.07 0.05], ...
    'string',initialStr);
set(handles.text_rippThresh,'string',thresh);

handles.numRipples = numRipples;
handles.text_ripp = text_ripp;
guidata(hObject,handles)

%% show different ripple
function updateRipple(hObject,~)

handles = guidata(hObject);
rippToShow = ceil(get(handles.slide_ripp,'value'));
xlim([handles.ripp_ints(rippToShow,1) - 2.5, handles.ripp_ints(rippToShow,1) + 2.5])
set(handles.text_ripp,'string',sprintf('%d of %d',rippToShow,handles.numRipples));

guidata(hObject,handles)

%% change ripple threshold
function updateThresh(hObject,eventData,filt_ripple,rsrate)

thresh = get(hObject,'string');
identifyRipples(hObject,eventData,filt_ripple,rsrate,str2double(thresh))



