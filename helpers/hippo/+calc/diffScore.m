
% Calculate difference score.
%
%   USAGE
%       score = calc.diffScore(x,y)
%       x           vector of values from session 1
%       y           vector of values from session 2
%
%   OUTPUTS
%       score       difference score
%
% Written by BRK 2017

function score = diffScore(x,y)

score = (y-x) ./ (y+x);