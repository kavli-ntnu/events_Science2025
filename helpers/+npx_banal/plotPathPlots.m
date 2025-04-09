function plotPathPlots(posT,posX,posY,sCell,nr,nc,unitIDs)

titles = false;
if exist('unitIDs', 'var')
    titles = true;
end
sub_pos = npx_banal.subs(nr,nc,titles);
c = 1;
for i = 1:nr
    for j = 1:nc
        axes('pos',sub_pos{i,j});
        plot(posX,posY,'-','color',ones(1,3)*0.5)
        hold on
        try
            spkPos = data.getSpikePositions(sCell{c},[posT posX posY]);
            scatter(spkPos(:,2),spkPos(:,3),8,'k','filled','markerfacealpha',0.8);
            h = title(sprintf('%s',unitIDs{c}),'fontsize',10,'fontweight','bold', 'interpreter', 'none');
            h.Position(2) = max(posY) + max(posY)*0.1;
        end
%         axis([-.8 .8 -.8 .8])
        axis equal, axis off
        c = c+1;
        if c > numel(sCell)
            return
        end
    end
end