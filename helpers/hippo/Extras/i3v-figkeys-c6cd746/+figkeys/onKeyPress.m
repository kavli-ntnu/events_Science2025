function  onKeyPress( hfig, evnt )
% Process user keypress - toggle zoom/pan mode
%
%% What keys to use?
%
% * SHIFT - using it here prevents user from creating multiple datatips
%           (the context menu "add new datatip" is broken)
%
%     Character: ''
%      Modifier: {'shift'}
%           Key: 'shift'
%
%
% * ALT - sets focus to the figure's main menu, which is not a real 
%         problem, but looks weired
%
%     Character: ''
%      Modifier: {'alt'}
%           Key: 'alt'
%    
%
% * CONTROL - works OK
%
%     Character: ''
%      Modifier: {'control'}
%           Key: 'control'
%
%
% * 'Z' - (and other printable keys) - works, but would be printed to
%         the Command Window, unless this function is called via
%         'KeyPressFcn', which is an issue, cause it gets overwritten
%         on MODE change.
%         (see notes in "setHotkeys.m" and "updateCallbacks.m")
%
%     Character: 'z'
%      Modifier: {''}
%           Key: 'z'
%


switch evnt.Key
    
    case 'x'    
        mode = 'Exploration.Pan';
        new_state = toggle(hfig,mode);
        pan(hfig,new_state)

    case 'z'
        mode = 'Exploration.ZoomIn';
        new_state = toggle(hfig,mode);
        zoom(hfig,new_state);   
    
    case 'c'
        mode = 'Exploration.Rotate';
        new_state = toggle(hfig,mode);
        rotate3d(hfig,new_state);   

    case 'v'
        mode = 'Exploration.DataCursor';
        new_state = toggle(hfig,mode);
        datacursormode(hfig,new_state);   
        
    otherwise            
        return; % ignore keypress
        
end

figkeys.updateCallbacks( hfig, mode );


end

function new_state = toggle(hfig,tag)    

    htb = figkeys.findToolbarButton(hfig,tag);
    
    switch htb.State
        
        case 'on'
            new_state = 'off';
            
        case 'off'
            new_state = 'on';
            
        otherwise
            error('figkeys:onKeyPress:unexpectedState',...
                  'Unexpected button state');              
              
    end
    
    
end

