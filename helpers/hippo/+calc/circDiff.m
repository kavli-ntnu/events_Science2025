
% Calculate circular difference between angles.
%
%   USAGE
%       diff = calc.circDiff(x,y,preserveSign)
%       x                   numeric array of angles (in degrees)
%       y                   numeric array of angles (in degrees)
%       preserveSign        (optional) 1 preserves direction of change, 0 does not (default)
%
%   OUTPUT
%       cDiff               signed circular difference (y-x)
%
% Written by BRK 2017

function cDiff = circDiff(x,y,preserveSign)

%% check inputs
if nargin < 2
    error('Not enough input arguments')
else
    if (helpers.isdvector(x,'>=0','<=360') + helpers.isdvector(y,'>=0','<=360')) < 2
        error('Inputs x and y must be vectors with values between 0 and 360')
    end
end

%% compute
cDiff = 180 - abs(180 - abs(y-x));

%% adjust sign
if nargin == 3
    if preserveSign == 1
        negs = (y-x) < 0;
        cDiff(negs) = cDiff(negs)*(-1);
    end
end