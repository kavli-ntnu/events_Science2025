% GUI to check BNT positions for errors, and exclude extra points if
% necessary. Works with BNT mat file ending in 'posClean' and overwrites
% the same file when points are excluded.
%
%   USAGE
%       minions.trackerChecker
%
%   SEE ALSO
%       data.getPositions
%
% Written by BRK 2017

function trackerChecker

%% create GUI
h.fig = figure('name','Position tracker checker','color',[0.85 0.85 0.85],'unit','norm');
set(h.fig,'position',[0 0 1 1])

% select masterMat file to extract folder names
h.butt_chooseMaster = uicontrol(h.fig,'style','pushbutton', ...
    'string','Select masterMat', ...
    'fontsize',15, ...
    'units','normalized', ...
    'position',[0.01 0.87 0.2 0.1], ...
    'callback',@populateListbox);

% select single folder
h.butt_chooseFolder = uicontrol(h.fig,'style','pushbutton', ...
    'string','Select folder(s)', ...
    'fontsize',15, ...
    'units','normalized', ...
    'position',[0.25 0.87 0.2 0.1], ...
    'callback',@populateListbox);

% list of available folders
h.listbox = uicontrol(h.fig,'style','listbox', ...
    'units','normalized', ...
    'position',[0.01 0.01 0.45 0.85], ...
    'min',0,'max',1, ... % allow one selection only
    'value',1, ...
    'callback',@sessionSelect);

% cut out bad position samples
h.butt_drawROI = uicontrol(h.fig,'style','pushbutton', ...
    'string','Exclude bad points', ...
    'fontsize',15, ...
    'units','normalized', ...
    'position',[0.55 0.87 0.3 0.1], ...
    'callback',@drawROI);
h.text = uicontrol(h.fig,'style','text', ...
    'units','normalized', ...
    'position',[0.55 0.805 0.3 0.05], ...
    'fontsize',12, ...
    'backgroundcolor',h.fig.Color, ...
    'string',sprintf('You can zoom or pan even during ROI selection\nby toggling on/off the buttons on the toolbar.'));

% show tracking data
h.axes = axes('position',[0.5 0.25 0.40 0.55],'xticklabels','','yticklabels','');

% create posClean file if one does not exist already (load data in BNT)
h.butt_getPosBNT = uicontrol(h.fig,'style','pushbutton', ...
    'string','Load positions with BNT', ...
    'fontsize',15, ...
    'units','normalized', ...
    'position',[0.5 0.12 0.2 0.1], ...
    'callback',@getPosBNT);
h.butt_clearCache = uicontrol(h.fig,'style','pushbutton', ...
    'string','Undo and reload with BNT', ...
    'fontsize',15, ...
    'units','normalized', ...
    'position',[0.5 0.01 0.2 0.1], ...
    'callback',@clearCache);

% create posClean file if one does not exist already (load data in BNT)
h.butt_fixChopped = uicontrol(h.fig,'style','pushbutton', ...
    'string','Attempt to fix chopped map', ...
    'fontsize',15, ...
    'units','normalized', ...
    'position',[0.7 0.12 0.2 0.1], ...
    'callback',@fixChopped);

    %% fill listbox with folder(s)
    function populateListbox(hObject,eventData)
        
        if strcmpi(eventData.Source.String,'Select masterMat')
            [name,path] = uigetfile('*.mat','Choose masterMat','multiselect','off');
            if name == 0; return; end;
            
            L = load(fullfile(path,name));
            raw = L.dataOutput;
            labels = L.labels;
            h.folders = unique(extract.cols(raw,labels,'folder'),'stable');
        else % not masterMat
            h.folders = uipickfilesBRK();
            if isnumeric(h.folders); return; end;
        end
        set(h.listbox,'value',1)
        set(h.listbox,'string',h.folders)
        sessionSelect();
        
    end

    %% when you click on a folder
    function sessionSelect(varargin)
        
        selected = get(h.listbox,'value');
        h.currFolder = h.folders{selected};
        
        myDir = dir(h.currFolder);
        h.names = extractfield(myDir,'name');
        ind = find(~cellfun(@isempty,strfind(h.names,'posClean.mat')));

        if length(ind) < 1 % no file
            cla(h.axes)
            axes(h.axes)
            text(0.5,0.5,'No posClean.mat file detected.','fontsize',15,'horiz','center')
            return
        elseif length(ind) > 1 % multiple files, check for updates
            posUpdates = 0;
            for i = 1:length(ind)
                load(fullfile(h.currFolder,h.names{ind(i)}),'info');
                if isfield(info,'manual') && info.manual
                    posUpdates = posUpdates + 1;
                end
            end
            if posUpdates > 0 % manual corrections, abort
                cla(h.axes)
                axes(h.axes)
                text(0.5,0.5,sprintf(['Multiple posClean.mat files detected,\n' ...
                    'probably from changing folder names.\n\n' ...
                    'Since some have been manually corrected, \n' ...
                    'need to delete unwanted cache files before continuing.']),'fontsize',15,'horiz','center')
                return
            else % no manual corrections, use file with matching folder name
                splits = regexp(h.currFolder,'\','split');
                ind = find(~cellfun(@isempty,strfind(h.names,[splits{end},'_posClean.mat'])));
            end
        end
        
        % check for old posCleans with corrections
        splits = regexp(h.currFolder,'\','split');
        posUpdates = false;
        if ~strcmpi(splits{end},h.names{ind}(1:end-13)) % don't have posClean that matches folder name
            load(fullfile(h.currFolder,h.names{ind}),'info');
            if isfield(info,'manual') && info.manual
                posUpdates = true;
            end
        end
        if posUpdates % found udpates, must abort
            cla(h.axes)
            axes(h.axes)
            text(0.5,0.5,sprintf(['Folder name has been changed and positions were\n' ...
                'previously corrected. Cannot continue.']),'fontsize',15,'horiz','center')
            return
        end
        
        L = load(fullfile(h.currFolder,h.names{ind}));
        h.positions = L.positions;
        h.info = L.info;
        if isfield(L,'creationTime')
            h.creationTime = L.creationTime;
        elseif isfield(h,'creationTime')
            rmfield(h,'creationTime');
        end
        
        axes(h.axes);
        plot(h.positions(:,2),h.positions(:,3),'.')
        set(gca,'ydir','reverse')
        
        h.ind = ind;
        
    end

    %% draw polygon to exclude some points
    function drawROI(varargin)
        
        try
            axes(h.axes);
            h1 = impoly;
            nodes = wait(h1);
            if isempty(nodes); return; end;
            try
                delete(h1)
            end
            positions = h.positions;
            toKeep = inpolygon(positions(:,2),positions(:,3),nodes(:,1),nodes(:,2));
            positions(~toKeep,2:end) = nan;

            info = h.info;
            dateTime = datestr(clock,30);
            info.manual = true;
            info.manualTimestamp = dateTime;
            info.manualNanInds = ~toKeep;
            
            if isfield(h,'creationTime')
                creationTime = h.creationTime;
                save(fullfile(h.currFolder,h.names{h.ind}),'positions','info','creationTime');
            else
                save(fullfile(h.currFolder,h.names{h.ind}),'positions','info');
            end
            fprintf('%s has been overwritten!\n',fullfile(h.currFolder,h.names{h.ind}))
            
            h.positions = positions;
            plot(h.positions(:,2),h.positions(:,3),'.')
            set(gca,'ydir','reverse')
            
        catch MSG
            cla(h.axes)
            warning('Positions not saved!')
            rethrow(MSG)
        end
    end

    %% load data with BNT
    function getPosBNT(varargin)
       
        global hippoGlobe
        writeInputBNT(hippoGlobe.inputFile,h.currFolder,hippoGlobe.arena,hippoGlobe.clusterFormat)
        data.loadSessions(hippoGlobe.inputFile);
        pos = data.getPositions();
        cla(h.axes)
        axes(h.axes)
        sessionSelect();
    end

    %% you made a mistake, delete cache and reload with BNT
    function clearCache(varargin)
       
        global hippoGlobe
        writeInputBNT(hippoGlobe.inputFile,h.currFolder,hippoGlobe.arena,hippoGlobe.clusterFormat)
        helpers.deleteCache(hippoGlobe.inputFile);
        fprintf('Cache has been deleted! %s\n',h.currFolder)
        data.loadSessions(hippoGlobe.inputFile);
        pos = data.getPositions();
        cla(h.axes)
        axes(h.axes)
        sessionSelect();
    end

    %% chopped maps
    function fixChopped(varargin)
       
        global hippoGlobe
        writeInputBNT(hippoGlobe.inputFile,h.currFolder,hippoGlobe.arena,hippoGlobe.clusterFormat)
        data.loadSessions(hippoGlobe.inputFile);
        
        % set dist thresh to inf to avoid chopping
        [p.distanceThreshold,p.maxInterpolationGap,p.posStdThreshold] = deal(inf,1,2.5);
        pos = data.getPositions('params',p);
        splits = regexp(h.currFolder,'\','split');
        
        % reset dist thresh to default to avoid posClean being overwritten
        % in the future
        load(fullfile(h.currFolder,[splits{end},'_posClean.mat']),'info');
        info.distanceThreshold = 150;
        dateTime = datestr(clock,30);
        info.manual = true;
        info.manualTimestamp = dateTime;
        save(fullfile(h.currFolder,[splits{end},'_posClean.mat']),'info','-append');
        
        cla(h.axes)
        axes(h.axes)
        sessionSelect();
    end


end