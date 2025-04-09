% Plot median values as horizontal bars on current axes.
%
%   USAGE
%       plt.medians(x,y,<options>)
%       x           vector of x values
%       y           vector of y values, or cell array of vectors with each group in a different cell
%       <options>   optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%       color       string or 3-element RGB vector specifying bar color
%       width       double specifying left-right width of bar(s)
%       weight      double specifying bar line weight
%
% Written by BRK 2017. 

function medians(x,y,varargin)

if mod(length(varargin),2) || nargin < 2
    error('Incorrect number of parameters.');
end
     
check{1} = @(x) helpers.isdscalar(x,'>=0');
check{2} = @(x) helpers.isstring(x) || helpers.isdvector(x,'>= 0');
check{3} = @(x) helpers.isdscalar(x,'>=0');

inp = inputParser;
addParameter(inp,'width',0.3,check{1});
addParameter(inp,'color','k',check{2});
addParameter(inp,'weight',3,check{3});
parse(inp,varargin{:});

width = inp.Results.width;
Color = inp.Results.color;
weight = inp.Results.weight;

hold on
if iscell(y)
    plot([x-width; x+width],[cellfun(@nanmedian,y); cellfun(@nanmedian,y)],'color',Color,'linew',weight)
else
    plot([x-width; x+width],[nanmedian(y); nanmedian(y)],'color',Color,'linew',weight)
end