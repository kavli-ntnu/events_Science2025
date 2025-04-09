function [maps, maps_struct] = maps(sCell,posT,posX,posY,boxSize,binWidth)

N = numel(sCell);
maps = cell(N,1);
maps_struct = cell(N,1);
c = 0;

if nargin < 5
    if range(posX) > 1.35 || range(posY) > 1.35
        boxSize = 150;
        binWidth = boxSize/40;
    else
        boxSize = 100;
        binWidth = boxSize/25;
    end
end

posX2 = minions.rescaleData(posX,0,boxSize);
posY2 = minions.rescaleData(posY,0,boxSize);
% posX2 = posX;
% posY2 = posY;
for iUnit = 1:N     
    c = c + 1;
    spkT = sCell{iUnit};
    map = analyses.map([posT, ...
        posX2, ...
        posY2],spkT,'binWidth',binWidth,'smooth',2); % 40 x 40 map
    maps(c) = {map.z};
    maps_struct(c) = {map};
end