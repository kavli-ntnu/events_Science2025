
% Pad a 3D matrix with nans in x and y, but not z.
%
%   USAGE
%       m = minions.nan_pad3(m,nPad)
%       m          3D input matrix
%       nPad       number of rows and columns of nans to add (symmetrical)
%
%   OUTPUT
%       m          3D matrix symmetrically padded with nans in x and y
%
%
% Written by BRK 2020 (brkanter[at]gmail[dot]com)

function m = nan_pad3(m,nPad)

nRows = size(m,1);
N = size(m,3);
m = cat(2,nan(nRows,nPad,N),m);
m = cat(2,m,nan(nRows,nPad,N));
nCols = size(m,2);
m = cat(1,nan(nPad,nCols,N),m);
m = cat(1,m,nan(nPad,nCols,N));