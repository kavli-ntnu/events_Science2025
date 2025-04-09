
% Scale data to have new min and max values.
%
%   USAGE
%       scaledData = minions.rescaleData(dataInput,newMin,newMax)
%       dataInput          numeric data array to scale
%       newMin             (optional) desired minimum (default = 0)
%       newMax             (optional) desired maximum (default = 1)
%
%   OUTPUT
%       scaledData         rescaled data
%
% Written by BRK 2017

function scaledData = rescaleData(dataInput,newMin,newMax)

%% check inputs
if nargin == 1
    newMin = 0;
    newMax = 1;
end

%% get min and max of data
oldMin = nanmin(dataInput(:));
oldMax = nanmax(dataInput(:));

if isempty(newMin)
    newMin = oldMin;
end
if isempty(newMax)
    newMax = oldMax;
end

%% get ranges
newRange = newMax - newMin;
if newRange < 0
    warning('New range has greater minimum than maximum! Values are inverted!')
end
oldRange = oldMax - oldMin;

%% rescale
scaledData = ((newRange * (dataInput - oldMin)) ./ oldRange) + newMin;
