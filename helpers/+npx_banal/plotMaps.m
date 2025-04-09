function plotMaps(m,nr,nc,unitIDs,cmap)

titles = false;
if exist('unitIDs', 'var')
    titles = true;
end
if ~exist('cmap', 'var')
    cmap = get(groot, 'defaultfigurecolormap');
end
sub_pos = npx_banal.subs(nr,nc,titles);

c = 1;
for i = 1:nr
    for j = 1:nc
        axes('pos',abs(sub_pos{i,j}));
        try
            colorMapBRK(m{c},'clrmap',cmap);
            if titles
                h = title(sprintf('%s',unitIDs{c}),'fontsize',10,'fontweight','bold', 'interpreter', 'none');
                h.Position(2) = size(m{c},1) + 2;
            end
        end
        axis square
        axis off
        c = c+1;
        if c > numel(m)
            return
        end
    end
end