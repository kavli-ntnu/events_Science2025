
% Pad a 2D matrix with nans.
%
%   USAGE
%       m = minions.nan_pad2(m,nPad)
%       m          2D input matrix
%       nPad       number of rows and columns of nans to add (symmetrical)
%
%   OUTPUT
%       m          2D matrix symmetrically padded with nans
%
%   EXAMPLE
%       m = [1 2
%            3 4]
%       m = minions.nan_pad2(m,3)
%       m = [nan nan nan nan nan nan nan nan
%            nan nan nan nan nan nan nan nan   
%            nan nan nan nan nan nan nan nan   
%            nan nan nan  1   2  nan nan nan
%            nan nan nan  3   4  nan nan nan
%            nan nan nan nan nan nan nan nan 
%            nan nan nan nan nan nan nan nan   
%            nan nan nan nan nan nan nan nan]
%
%
% Written by BRK 2020 (brkanter[at]gmail[dot]com)

function m = nan_pad2(m,nPad)

nRows = size(m,1);
m = [nan(nRows,nPad),m];
m = [m,nan(nRows,nPad)];
nCols = size(m,2);
m = [m;nan(nPad,nCols)];
m = [nan(nPad,nCols);m];