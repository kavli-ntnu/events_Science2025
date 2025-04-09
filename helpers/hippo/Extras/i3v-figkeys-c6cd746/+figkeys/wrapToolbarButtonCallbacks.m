function  wrapToolbarButtonCallbacks( hfig )
% Wrap toolbar button callbacks, so they would fix the point (4.ii),
% described in "updateCallbacks.m".
% 
% We manually check and modify each callback one-by-one, to reduce the
% chance to get unexpected result in non-tested Matlab versions.
% 
% Currently tested in:
% * R2015a
% * R2016a
%

mode = 'Exploration.ZoomIn';
htb1 = figkeys.findToolbarButton(hfig,mode);
assert(isequal(htb1.ClickedCallback,'putdowntext(''zoomin'',gcbo)'));
htb1.ClickedCallback = ...
    @(varargin) fkWrapper(hfig,'zoomin',mode);


mode = 'Exploration.ZoomOut';
htb2 = figkeys.findToolbarButton(hfig,mode);
assert(isequal(htb2.ClickedCallback,'putdowntext(''zoomout'',gcbo)'));
htb2.ClickedCallback = ...
    @(varargin) fkWrapper(hfig,'zoomout',mode);


mode = 'Exploration.Pan';
htb3 = figkeys.findToolbarButton(hfig,mode);
assert(isequal(htb3.ClickedCallback,'putdowntext(''pan'',gcbo)'));
htb3.ClickedCallback = ...
    @(varargin) fkWrapper(hfig,'pan',mode);


mode = 'Exploration.Rotate';
htb4 = figkeys.findToolbarButton(hfig,mode);
assert(isequal(htb4.ClickedCallback,'putdowntext(''rotate3d'',gcbo)'));
htb4.ClickedCallback = ...
    @(varargin) fkWrapper(hfig,'rotate3d',mode);


mode = 'Exploration.DataCursor';
htb5 = figkeys.findToolbarButton(hfig,mode);
assert(isequal(htb5.ClickedCallback,'putdowntext(''datatip'',gcbo)'));
htb5.ClickedCallback = ...
    @(varargin) fkWrapper(hfig,'datatip',mode);


mode = 'Exploration.Brushing';
htb6 = figkeys.findToolbarButton(hfig,mode);
assert(isequal(htb6.ClickedCallback,'putdowntext(''brush'',gcbo)'));
htb6.ClickedCallback = ...
    @(varargin) fkWrapper(hfig,'brush',mode);


end




function fkWrapper(hfig,passedArg,mode)
% Evaluate built-in matlab callback, and restore overwritten custom
% callbacks.

    putdowntext(passedArg,gcbo);
    figkeys.updateCallbacks(hfig,mode);
    
end