
function sub_pos = subs(nr,nc,titles,orientation)

if nargin > 3 && strcmpi('vertical', orientation)
    pageWidth = 21; % A4 paper
    pageHeight = 29.7;
else
    pageWidth = 29.7; % A4 paper
    pageHeight = 21;
end
spCols = nc;
spRows = nr;
leftEdge = 0.1 * 10;
rightEdge = 0.1;
topEdge = 0.1;
bottomEdge = 0.1 * 20;
spaceX = 0.5;
spaceY = 0.5;
if exist('titles', 'var') && titles
    topEdge = 0.6;
end
sub_pos = subplot_pos(pageWidth,pageHeight,leftEdge,rightEdge,topEdge,bottomEdge,spCols,spRows,spaceX,spaceY);

figure('PaperUnits','cent','PaperSize',[pageWidth pageHeight],'PaperPos',[0 0 pageWidth pageHeight],'units','norm','position',[0.5764,-0.2844,0.7549,1.1889]);
movegui