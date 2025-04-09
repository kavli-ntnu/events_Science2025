function  updateCallbacks( hfig, mode )
% Callback-based key-capturing method. Implemented as a standalone
% function, separately from "setHotkeys.m" to simplify the process of
% switching back to "v2", if needed:
%
% * Comment out "v1" part in "setHotkeys.m" and all code inside this
%   function. The function itself is still being executed.

%% A common part for v1.*
%
% refs:
% http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
% http://www.mathworks.com/matlabcentral/answers/51680-datacursormode-overwrites-keypressfcn-by-setting-in-protective-listeners-how-can-i-automatically-s
% http://www.mathworks.com/matlabcentral/answers/221613-how-to-keep-the-zoom-active-as-long-as-a-key-is-pressed
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/141886
% http://www.mathworks.com/matlabcentral/answers/109242-how-can-i-set-a-gui-callback-such-that-it-uses-the-up-to-date-handles-structure-as-an-input-variable
% http://www.mathworks.com/matlabcentral/answers/251339-re-enable-keypress-capture-in-pan-or-zoom-mode
%


% The workaround, to handle both HG1 and HG2:
%
hManager = uigetmodemanager(hfig);
try
    set(hManager.WindowListenerHandles, 'Enable', 'off');  % HG1
catch
   [hManager.WindowListenerHandles.Enabled] = deal(false);  % HG2
end



%% v1.1 WindowKeyPressFcn
%
%  set(hfig,...
%          'WindowKeyPressFcn',@(hobj,evnt) figkeys.onKeyPress(hobj,evnt));
%
% (1) Works only on the first key press, because the key is printed into
%     the Command Window -> current figure looses focus -> next keypress is
%     not captured. Cliking on the figure brings focus back, and re-enables
%     the functionality, but this is not very user-friendly, just like
%     printing keypresses to the Command Window. 
% 
% (2) A possible workaround for (1) is to use non-printable keys, like
%     SHIFT, ALT, CTRL. This is associated with other issues though 
%     (see "figkeys.onKeyPress")
%
% (3) If MODE is not toggeled, keypresses are not printed (why???)
%     Try commening out "zoom(hobj,new_state) and "pan(hobj,new_state)".
%
% (4) This callback get overwritten each time the MODE is toggeled, thus:
%   
%     i. Requires setHotkeys() at the end of onKeyPress()
%
%    ii. Requires some additional mechanism to call setHotkeys() if MODE is
%        toggled from another place. E.g. if user changed mode with a
%        toolbar button. Change toolbar button callbacks?
% 

%% v1.2 KeyPressFcn
set(hfig, 'WindowKeyPressFcn', []);
set(hfig, 'KeyPressFcn', @(hobj,evnt) figkeys.onKeyPress(hobj,evnt));

% (1) "KeyPressFcn" intercepts keypresses and they are not printed to the
%    command window. Still, it might be overwritten.
% 
% (2) Enabling both "WindowKeyPressFcn" and "KeyPressFcn" results in double
%     toggle: on -> off -> on. (Looks reasonable).
%
% (3) is similar to (4) in v1.1
% 

%% Change the behaviour for specific modes:

if exist('mode','var')
    htb=figkeys.findToolbarButton(hfig,mode);
    state = htb.State;
else
    state = 'off';
end


switch state
    case 'off'
        modeState = '';        
    case 'on'
        modeState = mode;
    otherwise
        error('figkeys:UnexpecteedNewState','unexpected state');
end
        

switch modeState
    
    case ''
        % normal mode, no buttons pressed, nothing
    
    case {'Exploration.ZoomIn','Exploration.ZoomOut',...
          'Exploration.Rotate',...
          'Exploration.DataCursor',...
          'Exploration.Brushing'...
          }
        % nothing
        
    case 'Exploration.Pan'
        % Make zooming with the mouse wheel availible in the "pan" mode as
        % well        
        set(hfig, 'WindowScrollWheelFcn',....
                           @(hobj,evnt) figkeys.onMouseWheel(hobj,evnt)  );
                       
                         
        
    otherwise
        erorr('figkeys:UnexpecteedNewMode','unexpected new "mode"');
end
  

end

