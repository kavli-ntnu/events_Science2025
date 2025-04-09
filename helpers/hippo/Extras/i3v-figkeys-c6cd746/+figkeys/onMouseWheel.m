function onMouseWheel( hfig, evnt )
%A special

htb3 = figkeys.findToolbarButton(hfig,'Exploration.Pan');

factor = exp(-0.15*evnt.VerticalScrollCount);
zoom(hfig,factor)

end

