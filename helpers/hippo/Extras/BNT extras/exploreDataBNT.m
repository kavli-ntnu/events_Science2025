
% Load data from a recording session with BNT so that all BNT functions are ready to use.
%
%   USAGE
%       exploreData
%
%   NOTES
%       This function is bare bones by design so that the user can add whatever information is relevant to them.
%
% Written by BRK 2017

function exploreDataBNT

%% get globals
global hippoGlobe
if isempty(hippoGlobe.inputFile)
    startup
end

%% choose recording session and load the data
folder = uigetdir();

% check for multiple sessions in single folder for Tint/Klusta data
if strcmpi(hippoGlobe.clusterFormat,'Tint')
    prompt={'If you have more than one session in that folder, enter the session name'};
    name='';
    numlines=1;
    defaultanswer={'10051302'};
    sessionName = inputdlg(prompt,name,numlines,defaultanswer,'on');
else
    sessionName = {};
end

% if there aren't any clusters, just plot the animal's path
try
    
    writeInputBNT(hippoGlobe.inputFile,folder,hippoGlobe.arena,hippoGlobe.clusterFormat,sessionName)
    
catch caughtErr
    
    if strcmpi(caughtErr.message,'Did not find any clusters.')
        
        % plot path
        warning('Did not find clusters, loading raw position data just to check animal''s exploration.')
        [x y] = io.neuralynx.Nlx2MatVT(fullfile(folder,'VT1.nvt'),[0 1 1 0 0],0,1);
        figure('name',folder);
        plot(x,y,'color',[0.5 0.5 0.5])
        axis off
        return
        
    else
        rethrow(caughtErr)
    end
    
end

data.loadSessions(hippoGlobe.inputFile)

%% plot animal's trajectory
figure('name',folder);
hold on
pathTrialBRK('color',[0.5 0.5 0.5])
axis off

%% display cluster list
clusterList = data.getCells;
display(sortrows(clusterList))

