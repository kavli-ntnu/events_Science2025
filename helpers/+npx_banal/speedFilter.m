
function [posX, posY, spd_sm, spd_raw] = speedFilter(posT, posX, posY, kernel, Filter)

N_pos = size(posX, 1);
spd = zeros(N_pos, 1);
for i = 2:(N_pos - 1)
    spd(i) = sqrt((posX(i+1) - posX(i-1))^2 + (posY(i+1) - posY(i-1))^2) / (posT(i+1) - posT(i-1));
end
spd(1) = spd(2);
spd(end) = spd(end - 1);
spd_raw = spd;
Fs = mode(diff(posT));
smWin = kernel * round(1/Fs);
spd_sm = general.smooth(spd, smWin);
if exist('Filter','var') && Filter
    if islogical(Filter)
        cutoff = 0.05; % 0.05 m = 5 cm
    else
        cutoff = Filter;
    end
    to_nan = (spd_sm < cutoff) | isnan(spd_sm);
    posX(to_nan) = nan;
    posY(to_nan) = nan;
end