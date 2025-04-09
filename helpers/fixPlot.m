function fixPlot(xTicks,xTickLabels,xLabel,yLabel)

%% font and box
ax = gca;
ax.FontSize = 14;
ax.FontWeight = 'bold';
ax.Box = 'off';

if nargin
    
    %% x-axis format
    if isnumeric(xTicks)
        ax.XTick = xTicks;
    end
    if all(strcmpi(xTickLabels,''))
        ax.XTickLabel = '';
    elseif ischar(xTickLabels) || iscell(xTickLabels)
        ax.XTickLabel = xTickLabels;
    end
    
    %% axis labels
    if nargin > 2
        xlabel(xLabel)
    end
    if nargin == 4
        ylabel(yLabel)
    end
    
end
