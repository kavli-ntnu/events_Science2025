
% Return length of recording session.
%
%   USAGE
%       minions.sessionLength
%
% Written by BRK 2016

function sessionLength

folder = uigetdir('','Select recording session');
fileEnding = dir(fullfile(folder,'*.nvt'));
filename = fullfile(folder,fileEnding.name);
TimeStamps = io.neuralynx.Nlx2MatVT(filename,[1 0 0 0 0 0],0,1);
fprintf('Recording is %.0f mins\n',length(TimeStamps)/25/60);