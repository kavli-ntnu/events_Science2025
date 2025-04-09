% This code is from the File Exchange, but seems to not be available there
% anymore. Edited by BRK 2017.

%%% --------------
% BRK flipped and transposed so that instead of reading up from bottom left, it reads right from top left. 
%
% Example:
%
% pageWidth = 29.7; % A4 paper
% pageHeight = 21;
% spCols = 2;
% spRows = 5;
% leftEdge = 1.5;
% rightEdge = 1.5;
% topEdge = 1.5;
% bottomEdge = 0.1;
% spaceX = 5;
% spaceY = 0.1;
% sub_pos = subplot_pos(pageWidth,pageHeight,leftEdge,rightEdge,topEdge,bottomEdge,spCols,spRows,spaceX,spaceY);
% 
% figure;
% set(gcf,'PaperUnits','cent','PaperSize',[pageWidth pageHeight],'PaperPos',[0 0 pageWidth pageHeight]);
% 
% for i = 1:spRows
%     for j = 1:spCols
%         axes('pos',sub_pos{i,j});
%         imagesc(magic(5))
%         axis off
%     end
% end
%
%
%%% --------------

function [positions] = subplot_pos(pageWidth,pageHeight,leftEdge,rightEdge,bottomEdge,topEdge,spCols,spRows,spaceX,spaceY)

    subxsize = (pageWidth-leftEdge-rightEdge-spaceX*(spCols-1.0))/spCols;
    subysize = (pageHeight-topEdge-bottomEdge-spaceY*(spRows-1.0))/spRows;
    
    for i = 1:spCols
       for j = 1:spRows
 
           xfirst = leftEdge+(i-1.0)*(subxsize+spaceX);
           yfirst = topEdge+(j-1.0)*(subysize+spaceY);
 
           % BRK change
%            positions{i,j} = [xfirst/pageWidth yfirst/pageHeight subxsize/pageWidth subysize/pageHeight];
           positions{j,i} = [xfirst/pageWidth yfirst/pageHeight subxsize/pageWidth subysize/pageHeight];
 
       end
    end

% BRK change    
positions = flipud(positions);
    
end