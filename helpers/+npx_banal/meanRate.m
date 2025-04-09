function mr = meanRate(sCell, posT)

mr = cellfun(@numel, sCell) / range(posT)';