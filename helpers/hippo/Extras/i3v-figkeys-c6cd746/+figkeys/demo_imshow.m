% Simple usage example for the figkeys.setHotkeys() function.
% Loads Matlab's built-in peppers image, to simplify testing of the 
% zoom/pan/rotate/datacursor modes switching.

hfig = figure;
imshow('peppers.png');
figkeys.setHotkeys(hfig);

% Note: one of the things to check is "whether custom hotkeys would work
%       after zoom/pan mode is toggled via a toolbar button".
