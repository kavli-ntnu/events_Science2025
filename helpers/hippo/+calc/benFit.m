
% Fit data with polynomial of your choice and return coefficient of determination.
%
%   USAGE
%       [R2,AR2,yfit] = calc.benFit(x,y,<options>)
%       x           vector of x values (independent variable)
%       y           vector of y values (dependent variable)
%       <options>   optional list of property-value pairs (see table below)
%
%   ============================================================================
%    Properties           Values
%   ----------------------------------------------------------------------------
%       degree      degree of polynomial fit (default = 1)
%       showLine    1 plots fit line, 0 does not (default) 
%   ============================================================================
%
%   OUTPUTS
%       R2          R squared
%       AR2         adjusted R squared
%       yfit        value of polynomial evaluated at x
%
% Written by BRK 2015

function [R2,AR2,yfit] = benFit(x,y,varargin)

%% parse inputs
check{1} = @(x) helpers.isdvector(x);
check{2} = @(x) helpers.isdvector(x);
check{3} = @(x) helpers.isiscalar(x,'>=0');
check{4} = @(x) helpers.isiscalar(x,'>=0','<=1');

inp = inputParser;
addRequired(inp,'x');
addRequired(inp,'y');
addParameter(inp,'degree',1,check{3});
addParameter(inp,'showLine',0,check{4});
parse(inp,x,y,varargin{:});

degree = inp.Results.degree;
showLine = inp.Results.showLine;

%% remove nans
xnan = isnan(x);
ynan = isnan(y);
x = x(~xnan & ~ynan);
y = y(~xnan & ~ynan);

[x, sortInd] = sort(x, 'ascend');
y = y(sortInd);

%% do the fit
p = polyfit(x,y,degree);
yfit = polyval(p, x);

%% get R vals
residY = y - yfit;
SSresid = sum(residY.^2);
SStotal = (length(y)-1) * var(y);
R2 = 1 - SSresid/SStotal;
AR2 = 1 - (SSresid/SStotal) * ((length(y)-1) / (length(y)-degree-1));

%% display results
% display(R2)
% display(AR2)

%% plot best fit line
if showLine
    hold on
    plot(x,yfit,'-','linewidth',2)
    hold off
end
