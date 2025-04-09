
% Remove rows or columns containing nans.
%
%   USAGE
%       array = minions.removeNans(array,dim,type)
%       array          2 dimensional double array of data
%       dim            'rows' or 'cols' to select what to remove
%       type           'all' requires all elements to be nans, 'any' requires any element to be nan
%
%   OUTPUT
%       array          array with specified nans removed
%
% Written by BRK 2017

function array = removeNans(array,dim,type)

%% check inputs
if nargin < 3
    error('Not enough input arguments')
else
    if numel(size(array)) ~= 2
        error('Expected array to be 2 dimensional.')
    end
    if ~helpers.isstring(dim,'rows','cols')
        error('Input #2 must be ''rows'' or ''cols''.')
    end
    if ~helpers.isstring(type,'all','any')
        error('Input #3 must be ''all'' or ''any''.')
    end
end

%% remove nans
if strcmpi(dim,'rows')
    if strcmpi(type,'all')
        array(all(arrayfun(@isnan,array),2),:) = [];
    elseif strcmpi(type,'any')
        array(any(arrayfun(@isnan,array),2),:) = [];
    end
    
elseif strcmpi(dim,'cols')
    if strcmpi(type,'all')
        array(:,all(arrayfun(@isnan,array),1)) = [];
    elseif strcmpi(type,'any')
        array(:,any(arrayfun(@isnan,array),1)) = [];
    end
end
