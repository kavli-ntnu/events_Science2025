
% Select which measures are calculated by emperorPenguin.
%
%   USAGE
%       [include,OK] = minions.emperorSettings
%
%   OUTPUT
%       include         structure indicating which measures to calculate
%       OK              logical indicating whether options were selected
%
%   SEE ALSO
%       meta.emperorPenguin minions.emperorHeadings
%
% Written by BRK 2017

function [include,OK] = emperorSettings()

include.spikeWidth = 0;
include.sss = 0;
include.coherence = 0;
include.fields = 0;
include.grid = 0;
include.HD = 0;
include.speed = 0;
include.theta = 0;
include.CC = 0;
include.obj = 0;

[selections, OK] = listdlg('PromptString','Select what to calculate', ...
    'ListString',{'Spike width (SLOW)', ...
    'Spat. info. content, selectivity, and sparsity (SLOW)', ...
    'Coherence','Field info and border scores', 'Grid stats','Head direction', ...
    'Speed score (SLOW)','Theta indices (SLOW)', ...
    'Spatial cross correlations','Objects'}, ...
    'InitialValue',1:9, ...
    'ListSize',[400, 250]);

if OK == 0; return; end;
if ismember(1,selections); include.spikeWidth = 1; end
if ismember(2,selections); include.sss = 1; end
if ismember(3,selections); include.coherence = 1; end
if ismember(4,selections); include.fields = 1; end
if ismember(5,selections); include.grid = 1; end
if ismember(6,selections); include.HD = 1; end
if ismember(7,selections); include.speed = 1; end
if ismember(8,selections); include.theta = 1; end
if ismember(9,selections); include.CC = 1; end
if ismember(10,selections); include.obj = 1; end