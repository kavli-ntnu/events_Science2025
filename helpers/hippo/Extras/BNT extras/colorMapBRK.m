%% BRK modifications to plot.colorMap

% flip ydir to compensate for camera
% add option for publication quality figures
% set aspect ratio

%%

% Plot a color map
%
% Plots a color map (e.g. the firing field of a place field)
%
%  USAGE
%   plot.colorMap(data, dimm, <options>)
%
%   data           data matrix MxN. M corresponds to rows(y), N to columns(x).
%   dimm           optional luminance map
%   <options>      optional list of property-value pairs (see table below)
%
%   =========================================================================
%    Properties    Values
%   -------------------------------------------------------------------------
%    'x'           abscissae
%    'y'           ordinates
%    'threshold'   dimm values below this limit are zeroed (default = 0.01)
%    'cutoffs'     lower and upper cutoff values ([] = autoscale, default)
%    'bar'         draw a color bar (default = 'off')
%    'ydir'        either 'normal' (default) or 'reverse' (useful when the
%                  x and y coordinates correspond to spatial positions,
%                  as video cameras can measure y in reverse direction)
%    'pubQual'**   interpolate map for finer smoothing,
%                  either 0 (default) or 1
%    'aspectRat'** set aspect ratio to something other than square (default)
%    'clrmap'**    colormap other than default
%
%   **BRK 2014
%   =========================================================================
%
%  NOTE
%
%   The luminance map is used to dimm the color map. A single scalar value
%   is interpreted as a constant luminance map. If this parameter is not
%   provided, normal equiluminance is assumed (i.e. scalar value of 1).
%
%   NaN values in map are displayed with white color.
%
%  EXAMPLE
%
%   fm = analyses.map(positions, spikes);      % firing map for a place cell
%   figure; plot.colorMap(fm.z, fm.time);      % plot, dimming with occupancy map
%
%  SEE
%   See also analyses.map.

% Copyright (C) 2004-2011 by Michaël Zugaro
% (C) 2013 by Vadim Frolov
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

function [scaleBar, hSurf] = colorMapBRK(data, dimm, varargin)
    % Default values
    cutoffs = [];
    threshold = 0.01;
    drawBar = 0;
    [y, x] = size(data);
    x = 1:x; y = 1:y;
    ydir = 'normal';
    scaleBar = 0;
    hSurf = 0;
    pubQual = 0;
    aspectRat = [1 1 1];
    inputMap = data;
    
    if nargin < 1,
        error('Incorrect number of parameters (type ''help <a href="matlab:help plot.colorMap">plot.colorMap</a>'' for details).');
    end
    if nargin == 1,
        dimm = 1;
    end
    if isa(dimm,'char')
        varargin = [{dimm} varargin];
        dimm = 1;
    end

    % Parse parameter list
    for i = 1:2:length(varargin)
        if ~ischar(varargin{i})
            error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help plot.colorMap">plot.colorMap</a>'' for details).']);
        end
        switch(lower(varargin{i}))
            case 'threshold',
                threshold = varargin{i+1};
                if ~helpers.isdscalar(threshold, '>=0')
                    error('Incorrect value for property ''threshold'' (type ''help <a href="matlab:help plot.colorMap">plot.colorMap</a>'' for details).');
                end

            case 'x',
                x = varargin{i+1};
                if ~helpers.isdvector(x)
                    error('Incorrect value for property ''x'' (type ''help <a href="matlab:help plot.colorMap">plot.colorMap</a>'' for details).');
                end

            case 'y',
                y = varargin{i+1};
                if ~helpers.isdvector(y)
                    error('Incorrect value for property ''y'' (type ''help <a href="matlab:help plot.colorMap">plot.colorMap</a>'' for details).');
                end

            case 'cutoffs',
                cutoffs = varargin{i+1};
                if ~helpers.isdvector(cutoffs, '#2', '<')
                    error('Incorrect value for property ''cutoffs'' (type ''help <a href="matlab:help plot.colorMap">plot.colorMap</a>'' for details).');
                end

            case 'bar',
                drawBar = lower(varargin{i+1});
                if ~helpers.isstring(drawBar,'on','off')
                    error('Incorrect value for property ''bar'' (type ''help <a href="matlab:help plot.colorMap">plot.colorMap</a>'' for details).');
                end

            case 'ydir',
                ydir = lower(varargin{i+1});
                if ~helpers.isstring(ydir,'normal','reverse')
                    error('Incorrect value for property ''ydir'' (type ''help <a href="matlab:help plot.colorMap">plot.colorMap</a>'' for details).');
                end
            %% BRK    
            case 'pubqual',
                pubQual = lower(varargin{i+1});
            case 'aspectrat',
                aspectRat = lower(varargin{i+1});
            case 'clrmap',
                clrMap = lower(varargin{i+1});
            %%
            
            otherwise,
                error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help <a href="matlab:help plot.colorMap">plot.colorMap</a>'' for details).']);
        end
    end

    if ~isempty(cutoffs),
        m = cutoffs(1);
        M = cutoffs(2);
    else
        m = min(min(data));
        M = max(max(data));
    end
    if m == M, M = m+1; end
    if isnan(m), m = 0; M = 1; end

    if length(dimm) == 1,
        dimm = dimm * ones(size(data));
    end

    a = gca;
    %% BRK
    if exist('clrMap','var')
        colormap(a,clrMap)
    else
        colormap(a,get(groot,'defaultfigurecolormap'));
    end
    cmap = colormap(gca);
    %%
    
    %% BRK  
    if pubQual
        numBinsX = size(inputMap,1);
        numBinsY = size(inputMap,2);
        data2 = inpaint_nans(inputMap);                      % guess at what nans would have been
        [xi, yi] = meshgrid(1:0.1:numBinsX,1:0.1:numBinsY);  % make a finer grid
        z = interp2(inputMap,xi,yi,'nearest');               % track nans to be filled back in
        z2 = interp2(data2,xi,yi,'bicubic');                 % interpolate image onto finer grid
        mask = isnan(z);                                     % fill nans back into image
        z2(mask) = NaN;
        hSurf = surface(z2);
        shading flat;
        lighting phong;
        % scale fig to include only visited pixels
%         xmin = find(any(z2,1),1,'first');
%         xmax = find(any(z2,1),1,'last');
%         ymin = find(any(z2,2),1,'first');
%         ymax = find(any(z2,2),1,'last');
%         axis([xmin xmax ymin ymax])
    else
        if ~isempty(find(isnan(data), 1))
            m = m - ((M - m)/length(x)); % length(x) is just arbitary. the goal is to set NaN to be less than minimum.
            data(isnan(data)) = m;
            % set background color as first color for NaNs
            cmap = [get(a,'color'); cmap];
        end
        p = imagesc(x, y, data, [m M]);
        colormap(a,cmap);
%         set(a, 'color', [0 0 0]);
        set(p,'hittest','off')
        if any(dimm~=1)
            alpha(p, 1 ./ (1 + threshold./(dimm+eps)));
        end
    end
    %%
    
    set(a, 'ydir', ydir, 'tickdir', 'out', 'box', 'off');

    if strcmp(drawBar, 'on'),
        scaleBar = colorbar('vert');
        set(scaleBar,'tickdir', 'out', 'box', 'off');
%         axes(a);
    end
    
    %% BRK
    set(gca,'DataAspectRatio',aspectRat)
    axis off
    %%
    
end