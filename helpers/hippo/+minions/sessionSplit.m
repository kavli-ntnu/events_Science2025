
% Split data from recording session into 2 pieces.
%
%   USAGE
%       minions.sessionSplit
%
% Written by BRK 2018

function sessionSplit

%% overwrite warning
h = warndlg(sprintf(['MAKE A BACKUP FIRST!!\n\nThis function writes files and an error could delete your data.\n\n', ...
    'Click cancel at any of the following prompts to quit.']));
waitfor(h)

%% choose session
folder1 = uigetdir('E:\','Choose recording sesson');
if ~folder1, return, end
folder2 = uigetdir('E:\','Choose EMPTY folder for times before the split');
if ~folder2, return, end
folder3 = uigetdir('E:\','Choose EMPTY folder for times after the split');
if ~folder3, return, end

%% CSC files (LFP)
fileEndings1 = dir(fullfile(folder1,'*.ncs'));
numCSCs = length(fileEndings1);
for iFile = 1:numCSCs
    filenames1{iFile} = fullfile(folder1, fileEndings1(iFile).name);
end
for iFile = 1:numCSCs
    filenames2{iFile} = fullfile(folder2, fileEndings1(iFile).name);
end
for iFile = 1:numCSCs
    filenames3{iFile} = fullfile(folder3, fileEndings1(iFile).name);
end
for iFile = 1:numCSCs
    [Timestamp{1,iFile}, ChanNum{1,iFile}, SampleFrequency{1,iFile}, NumValSamples{1,iFile}, Samples{1,iFile}, Header{1,iFile}] = io.neuralynx.Nlx2MatCSC(filenames1{iFile}, [1 1 1 1 1], 1, 1);
    if iFile == 1
       h = figure;
       plot(Timestamp{1,iFile}/1000000,Samples{1,iFile}(1,:),'.-')
       xlabel 'Time (sec)'
       title('Zoom in and use data cursor to identify timestamp to make the split. Then close figure.')
       waitfor(h)
       Answer = inputdlg('Enter timestamp for split (sec)','',1,{'1'});
       if isempty(Answer); return; end;
       timeSplitCSC = knnsearch(Timestamp{1,iFile}',str2double(Answer{1})*1000000);
    end

    Mat2NlxCSC(filenames2{iFile}, 0, 5, Timestamp{1,iFile}(1:timeSplitCSC), [1 1 1 1 1 1], Timestamp{1,iFile}, ChanNum{1,iFile}, SampleFrequency{1,iFile}, NumValSamples{1,iFile}, Samples{1,iFile}, Header{1,iFile});
    Mat2NlxCSC(filenames3{iFile}, 0, 5, Timestamp{1,iFile}(timeSplitCSC+1:end), [1 1 1 1 1 1], Timestamp{1,iFile}, ChanNum{1,iFile}, SampleFrequency{1,iFile}, NumValSamples{1,iFile}, Samples{1,iFile}, Header{1,iFile});
%     Mat2NlxCSC(filenames3{iFile}, 0, 1, 1, [1 1 1 1 1 1], Timestamp{3,iFile}, ChanNum{3,iFile}, SampleFrequency{3,iFile}, NumValSamples{3,iFile}, Samples{3,iFile}, Header{3,iFile});    
end

%% NTT files (spikes)
fileEndings1 = dir(fullfile(folder1,'*.ntt'));
for iFile = 1:4
    filenames1{iFile} = fullfile(folder1, fileEndings1(iFile).name);
end
for iFile = 1:4
    filenames2{iFile} = fullfile(folder2, fileEndings1(iFile).name);
end
for iFile = 1:4
    filenames3{iFile} = fullfile(folder3, fileEndings1(iFile).name);
end
for iFile = 1:4
    [Timestamps{1,iFile}, ScNumbers{1,iFile}, CellNumbers{1,iFile}, Params{1,iFile}, DataPoints{1,iFile}, Header{1,iFile}] = Nlx2MatSpike(filenames1{iFile}, [1 1 1 1 1], 1, 1);
    timeSplitSpike = knnsearch(Timestamps{1,iFile}',Timestamp{1,iFile}(timeSplitCSC));
    Mat2NlxSpike(filenames2{iFile}, 0, 5, Timestamps{1,iFile}(1:timeSplitSpike), [1 1 1 1 1 1], Timestamps{1,iFile}, ScNumbers{1,iFile}, CellNumbers{1,iFile}, Params{1,iFile}, DataPoints{1,iFile}, Header{1,iFile})
    Mat2NlxSpike(filenames3{iFile}, 0, 5, Timestamps{1,iFile}(timeSplitSpike+1:end), [1 1 1 1 1 1], Timestamps{1,iFile}, ScNumbers{1,iFile}, CellNumbers{1,iFile}, Params{1,iFile}, DataPoints{1,iFile}, Header{1,iFile})
end

%% NVT files (video)
fileEndings1 = dir(fullfile(folder1,'*.nvt'));
filenames1 = fullfile(folder1, fileEndings1.name);
filenames2 = fullfile(folder2, fileEndings1.name);
filenames3 = fullfile(folder3, fileEndings1.name);
[TimeStamps{1,1}, ExtractedX{1,1}, ExtractedY{1,1}, ExtractedAngle{1,1}, Targets{1,1}, Points{1,1}, Header{1,1}] = Nlx2MatVT( filenames1, [1 1 1 1 1 1], 1, 1);

timeSplitVideo = knnsearch(TimeStamps{1,1}',Timestamp{1,1}(timeSplitCSC));
Mat2NlxVT(filenames2, 0, 5, TimeStamps{1,1}(1:timeSplitVideo), [1 1 1 1 1 1 1], TimeStamps{1,1}, ExtractedX{1,1}, ExtractedY{1,1}, ExtractedAngle{1,1}, Targets{1,1}, Points{1,1}, Header{1,1})
Mat2NlxVT(filenames3, 0, 5, TimeStamps{1,1}(timeSplitVideo:end), [1 1 1 1 1 1 1], TimeStamps{1,1}, ExtractedX{1,1}, ExtractedY{1,1}, ExtractedAngle{1,1}, Targets{1,1}, Points{1,1}, Header{1,1})

