function  setHotkeys( hfig )
% Set zoom/pan hotkeys for the desired figure.
%
%% HOTKEYS:
%
% * 'z' - toogles zoom mode ( last used of zoom-in and zoom-out - assumes
%         that mouse wheel is used to change the zoom level )
% 
% * 'x' - toggles pan mode. Also adds zooming-with-mouse-wheel.
% 
% * 'c' - toggles rotation mode
%
% * 'v' - toggles datacursor mode
%
%% USAGE EXAMPLE:
%
% hfig = figure;
% imshow('peppers.png');
% figkeys.setHotkeys(hfig);
% 
%
%% INPUT
%   hfig - figure handle. Defaults to gcf() if ommited.
% 
% see also: test_on_imshow


if ~exist('hfig','var'); hfig =gcf;end;

%% v1 
figkeys.updateCallbacks(hfig);
figkeys.wrapToolbarButtonCallbacks(hfig);

%% v2 (currently disabled)
% (1) Same as for v1 (see "updateCallbacks.m")
%
% (2) If MODE is not toggeled, keypresses are still printed.
%     Try commening out "zoom(hobj,new_state) and "pan(hobj,new_state)".
%
% (3) This callback does not get overwritten when the MODE is toggeled.
%     That's why it's best for now.

% addlistener(hfig,...
%            'WindowKeyPress',@(hobj,evnt) figkeys.onKeyPress(hobj,evnt));



end

