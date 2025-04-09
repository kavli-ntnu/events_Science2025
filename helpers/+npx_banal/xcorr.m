
function si = xcorr(sCell,width,refIdx,oldSi)

if exist('oldSi','var')
    reSort = true;
else
    reSort = false;
end

binSize = width/500; % in seconds
xrange = -width:binSize:width;
nBins = length(xrange);

N_sub = ceil(sqrt(numel(refIdx)));

figure
cnt = 1;
for j = refIdx

    clear xc xi
    refSpikes = sCell{j};
    
    c = 0;
    for i = 1:numel(sCell)
        c = c + 1;
        if isempty(sCell{i})
            xi(c) = nan; xc(c,:) = nan(1,nBins);
        else
            try
                tmp = MClustStats.CrossCorr(sCell{i},refSpikes,binSize,nBins);
                xc(c,:) = minions.rescaleData(general.smooth(tmp,10));
            catch
                xc(c,:) = nan(1,nBins);
            end
            try
                xi(c) = find(max(xc(c,502:end)) == xc(c,502:end),1);
            catch
                xi(c) = 1;
            end
        end
    end
    
    
    [~,si{j}] = sort(xi,'ascend','missing','last');
    if reSort
        xc = xc(oldSi{j},:);
    else
        xc = xc(si{j},:);
    end
    if numel(refIdx) > 1
        subplot(N_sub,N_sub,cnt)
    end
    imagesc(xc(:,502:end))
    fixPlot(0:100:500,{(0:100:500)*binSize},'Time (sec)','Cell ID')
    
    cnt = cnt+1;
end