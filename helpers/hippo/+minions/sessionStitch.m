
% Merge data from 2 recording sessions and save in a new location (i.e. keeps originals).
%
%   USAGE
%       minions.sessionStitch
%
% Written by BRK 2016

function sessionStitch

%% overwrite warning
choice = questdlg('In the 3rd dialog box, choose an EMPTY folder for the new data. Otherwise you can overwrite data by accident. Be sure to read the dialog box titles for instructions. Are you ready to continue?', ...
    'WAIT!!', ...
    'No, I don''t get it','Let''s do it.','No, I don''t get it');
if ~strcmp(choice, 'Let''s do it.')
    return
end

%% choose 2 sessions to stitch
folder1 = uigetdir('E:\','Choose folder for FIRST recording sesson');
folder2 = uigetdir('E:\','Choose folder for SECOND recording session');
folder3 = uigetdir('E:\','Choose EMPTY folder for NEWLY STITCHED recording session');

%% CSC files (LFP)
fileEndings1 = dir(fullfile(folder1,'*.ncs'));
numCSCs = length(fileEndings1);
for iFile = 1:numCSCs
    filenames1{iFile} = fullfile(folder1, fileEndings1(iFile).name);
end
fileEndings2 = dir(fullfile(folder2,'*.ncs'));
for iFile = 1:numCSCs
    filenames2{iFile} = fullfile(folder2, fileEndings2(iFile).name);
end
for iFile = 1:numCSCs
    filenames3{iFile} = fullfile(folder3, fileEndings1(iFile).name);
end
for iFile = 1:numCSCs
    [Timestamp{1,iFile}, ChanNum{1,iFile}, SampleFrequency{1,iFile}, NumValSamples{1,iFile}, Samples{1,iFile}, Header{1,iFile}] = io.neuralynx.Nlx2MatCSC(filenames1{iFile}, [1 1 1 1 1], 1, 1);
    [Timestamp{2,iFile}, ChanNum{2,iFile}, SampleFrequency{2,iFile}, NumValSamples{2,iFile}, Samples{2,iFile}, Header{2,iFile}] = io.neuralynx.Nlx2MatCSC(filenames2{iFile}, [1 1 1 1 1], 1, 1); %#ok<*SAGROW>
    % shift back to 0, shift to end of first file, shift by one sample, append to first file
    Timestamp{3,iFile} = horzcat(Timestamp{1,iFile},Timestamp{2,iFile} - Timestamp{2,iFile}(1) + Timestamp{1,iFile}(end)  + (Timestamp{1,iFile}(end) - Timestamp{1,iFile}(end-1)));
    ChanNum{3,iFile} = horzcat(ChanNum{1,iFile},ChanNum{2,iFile});
    SampleFrequency{3,iFile} = horzcat(SampleFrequency{1,iFile},SampleFrequency{2,iFile});
    NumValSamples{3,iFile} = horzcat(NumValSamples{1,iFile},NumValSamples{2,iFile});
    Samples{3,iFile} = horzcat(Samples{1,iFile},Samples{2,iFile});
    try
        Header{3,iFile} = horzcat(Header{1,iFile},Header{2,iFile});
        io.neuralynx.Mat2NlxCSC(filenames3{iFile}, 0, 1, 1, [1 1 1 1 1 1], Timestamp{3,iFile}, ChanNum{3,iFile}, SampleFrequency{3,iFile}, NumValSamples{3,iFile}, Samples{3,iFile}, Header{3,iFile});
    catch
        io.neuralynx.Mat2NlxCSC(filenames3{iFile}, 0, 1, 1, [1 1 1 1 1 0], Timestamp{3,iFile}, ChanNum{3,iFile}, SampleFrequency{3,iFile}, NumValSamples{3,iFile}, Samples{3,iFile});
    end
end

%% NTT files (spikes)
fileEndings1 = dir(fullfile(folder1,'*.ntt'));
for iFile = 1:4
    filenames1{iFile} = fullfile(folder1, fileEndings1(iFile).name);
end
fileEndings2 = dir(fullfile(folder2,'*.ntt'));
for iFile = 1:4
    filenames2{iFile} = fullfile(folder2, fileEndings2(iFile).name);
end
for iFile = 1:4
    filenames3{iFile} = fullfile(folder3, fileEndings1(iFile).name);
end
for iFile = 1:4
    [Timestamps{1,iFile}, ScNumbers{1,iFile}, CellNumbers{1,iFile}, Params{1,iFile}, DataPoints{1,iFile}, Header{1,iFile}] = io.neuralynx.Nlx2MatSpike(filenames1{iFile}, [1 1 1 1 1], 1, 1);
    [Timestamps{2,iFile}, ScNumbers{2,iFile}, CellNumbers{2,iFile}, Params{2,iFile}, DataPoints{2,iFile}, Header{2,iFile}] = io.neuralynx.Nlx2MatSpike(filenames2{iFile}, [1 1 1 1 1], 1, 1); %#ok<*SAGROW>
    Timestamps{3,iFile} = horzcat(Timestamps{1,iFile},Timestamps{2,iFile} - Timestamps{2,iFile}(1) + Timestamps{1,iFile}(end)  + (Timestamps{1,iFile}(end) - Timestamps{1,iFile}(end-1)));
    ScNumbers{3,iFile} = horzcat(ScNumbers{1,iFile},ScNumbers{2,iFile});
    CellNumbers{3,iFile} = horzcat(CellNumbers{1,iFile},CellNumbers{2,iFile});
    Params{3,iFile} = horzcat(Params{1,iFile},Params{2,iFile});
    DataPoints{3,iFile} = cat(3,DataPoints{1,iFile},DataPoints{2,iFile});
    try
        Header{3,iFile} = horzcat(Header{1,iFile},Header{2,iFile});
        io.neuralynx.Mat2NlxSpike(filenames3{iFile}, 0, 1, 1, [1 1 1 1 1 1], Timestamps{3,iFile}, ScNumbers{3,iFile}, CellNumbers{3,iFile}, Params{3,iFile}, DataPoints{3,iFile}, Header{3,iFile})
    catch
        io.neuralynx.Mat2NlxSpike(filenames3{iFile}, 0, 1, 1, [1 1 1 1 1 0], Timestamps{3,iFile}, ScNumbers{3,iFile}, CellNumbers{3,iFile}, Params{3,iFile}, DataPoints{3,iFile})
    end
end

%% NVT files (video)
fileEndings1 = dir(fullfile(folder1,'*.nvt'));
filenames1 = fullfile(folder1, fileEndings1.name);
fileEndings2 = dir(fullfile(folder2,'*.nvt'));
filenames2 = fullfile(folder2, fileEndings2.name);
filenames3 = fullfile(folder3, fileEndings1.name);
[TimeStamps{1,1}, ExtractedX{1,1}, ExtractedY{1,1}, ExtractedAngle{1,1}, Targets{1,1}, Points{1,1}, Header{1,1}] = io.neuralynx.Nlx2MatVT( filenames1, [1 1 1 1 1 1], 1, 1);
[TimeStamps{2,1}, ExtractedX{2,1}, ExtractedY{2,1}, ExtractedAngle{2,1}, Targets{2,1}, Points{2,1}, Header{2,1}] = io.neuralynx.Nlx2MatVT( filenames2, [1 1 1 1 1 1], 1, 1);
TimeStamps{3,1} = horzcat(TimeStamps{1,1},TimeStamps{2,1} - TimeStamps{2,1}(1) + TimeStamps{1,1}(end)  + (TimeStamps{1,1}(end) - TimeStamps{1,1}(end-1)));
ExtractedX{3,1} = horzcat(ExtractedX{1,1},ExtractedX{2,1});
ExtractedY{3,1} = horzcat(ExtractedY{1,1},ExtractedY{2,1});
ExtractedAngle{3,1} = horzcat(ExtractedAngle{1,1},ExtractedAngle{2,1});
Targets{3,1} = horzcat(Targets{1,1},Targets{2,1});
Points{3,1} = horzcat(Points{1,1},Points{2,1});
try
    Header{3,1} = horzcat(Header{1,1},Header{2,1});
    io.neuralynx.Mat2NlxVT(filenames3, 0, 1, 1, [1 1 1 1 1 1 1], TimeStamps{3,1}, ExtractedX{3,1}, ExtractedY{3,1}, ExtractedAngle{3,1}, Targets{3,1}, Points{3,1}, Header{3,1})
catch
    io.neuralynx.Mat2NlxVT(filenames3, 0, 1, 1, [1 1 1 1 1 1 0], TimeStamps{3,1}, ExtractedX{3,1}, ExtractedY{3,1}, ExtractedAngle{3,1}, Targets{3,1}, Points{3,1})
end
