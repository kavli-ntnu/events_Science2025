% Plot turning data on a circular plot
%
% The main purpose of this function is to create a head direction and trajectory plots.
%
% The typical workflow is that one plots a head direction plot and then a trajectory plot
% on top. In this case the first function call should be with 'adjustAxis' == true and the second
% one with 'adjustAxis' == false.
%
%  USAGE
%
%    plot.circularTurning(data, options)
%    data           Distribution of some value across a circle (0-360 °).
%                   For example, for turning curve this will be a histogram
%                   of times spent at a particular angle during spikes.
%    <options>      optional list of property-value pairs (see table below)
%                   Options from the table are used by this function. All other
%                   options will be passed to Matlab's <a href="matlab:help plot">plot</a> function.
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'adjustAxis'  Flag that indicates whether axis should be adjusted to fit the data.
%                   Default is TRUE. If FALSE, then function will just plot the data
%                   in current axis. Adjustment involves setting new axis limits.
%     'ydir'        Either 'normal' (default) or 'reverse' (useful when the
%                   x and y coordinates correspond to spatial positions,
%                   as video cameras can measure y in reverse direction)
%    =========================================================================
%
function circularTurningBRK(data, varargin)
    if nargin < 1
        error('Incorrect number of parameters (type ''help <a href="matlab:help plot.circularTurning">plot.circularTurning</a>'' for details).');
    end

    adjustAxis = true;
    ydir = 'normal';

    removeInd = [];

    % Parse parameter list
    i = 1;
    while i < length(varargin)
        if ~ischar(varargin{i}),
            i = i + 1;
            continue;
        end

        switch(lower(varargin{i})),
            case 'adjustaxis',
                adjustAxis = varargin{i+1};
                removeInd = [i i+1];
                i = i + 2;
                break;
            case 'ydir',
                ydir = varargin{i+1};
                removeInd = [i i+1];
                i = i + 2;
                break;
        end
        i = i + 1;
    end
    varargin(removeInd) = [];

    minX = 999;
    maxX = -1;
    minY = 999;
    maxY = -1;
    minValue = 999;
    maxValue = -1;

    l = length(data);
    angles = 0:2*pi/l:2*pi;

    for i = 1:length(varargin)
        if strcmpi(varargin{i}, 'angles')
            angles = varargin{i+1};
            varargin(i:i+1) = [];
            break;
        end
    end

    if length(data) ~= length(angles)
        data(end+1) = data(1); % make closed figure
    end

    if size(data, 1) > 2
        data = data'; % transpose data to compute x,y
    end

    if ~isequal(size(data), size(angles'))
        angles = angles';
    end

    isNormalized = max(data) == 1;

    % get X and Y coordinates of turning directions
    x = cos(angles') .* data;
    y = sin(angles') .* data;

    minX = min([x minX]);
    maxX = max([x maxX]);

    minY = min([y minY]);
    maxY = max([y maxY]);

    if isNormalized
        axisMin = -1;
        axisMax = 1;
    else
        minValue = min([minX minY]);
        maxValue = max([maxX maxY]);
        maxValue = max(abs([minValue maxValue]));

        addL = 0.1 * maxValue; % extend the axis just a bit around the maximum value

        axisMin = -maxValue - addL;
        axisMax = maxValue + addL;
    end

    if adjustAxis
        axis([axisMin axisMax axisMin axisMax]);
    end

%     hold on;
    %% BRK
    plot(x, y, varargin{:});
    if strcmpi(ydir,'reverse')
        set(gca,'ydir','reverse')
    end
    %%
        
    if adjustAxis
        line([axisMin axisMax], [0 0], 'LineWidth', 0.5, 'color', 'k'); % x-axis
        line([0 0], [axisMin axisMax], 'linewidth', 0.5, 'color', 'k'); % y-axis

%         hold off;
        axis off;
    end
%     hold off;
end
