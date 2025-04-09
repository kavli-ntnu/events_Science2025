function htb = findToolbarButton(hfig,tag)
% Find handle of the toolbar button via it's tag. 
% 
% The list of tags of a regular figure (left-to-right):
%
%     'Standard.NewFigure'
%     'Standard.FileOpen'
%     'Standard.SaveFigure'
%     'Standard.PrintFigure'
%     'Standard.EditPlot'
%     'Exploration.ZoomIn'  
%     'Exploration.ZoomOut'
%     'Exploration.Pan'
%     'Exploration.Rotate'
%     'Exploration.DataCursor'
%     'Exploration.Brushing'
%     'DataManager.Linking'
%     'Annotation.InsertColorbarhtbA'
%     'Annotation.InsertLegend'
%     'Plottools.PlottoolsOff'
%     'Plottools.PlottoolsOn'

    ht = findall(hfig,'Type','uitoolbar');
    htbA=getAllChildren(ht);

    % We have to use getprop-or-empty() because the array htbA appears to
    % be heterogeneous, and some its elements may miss "Tag" property.
    tagC = cell(1,numel(htbA));
    for i=1:numel(htbA)
        if isprop(htbA(i),'Tag')
            tagC{i} = htbA(i).Tag;
        end
    end
    
    [TF,loc]=ismember(tag,tagC);
    assert(sum(TF)==1);

    htb = htbA(loc);
end


function children = getAllChildren( hObject )
% Performs  ch = get(hObject,'children') with ShowHiddenHandles == 'on'

old=get(0,'ShowHiddenHandles');
tmp=onCleanup(@() set(0,'ShowHiddenHandles',old));

set(0,'ShowHiddenHandles','on');
children = get(hObject,'children');

delete(tmp);

end





