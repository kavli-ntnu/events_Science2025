
% Extract positions and spikes from specific time block of session.
%
%   USAGE
%       [pos_block,spikes_block] = minions.sessionBlocks(pos,spikes,numBlocks,block)
%       pos               N x 3 numeric array of position data (t, x, y) 
%                        (N x 5 is okay if you have t, x1, y1, x2, y2)
%       spikes            numeric vector of spike times
%       numBlocks         double indicating number of total blocks
%       block             double indicating block to extract
%
%   OUTPUT
%       pos_block         desired block of position data (same size as pos)
%       spikes_block      spike times in block
%
%   EXAMPLES
%       % split 2 hr recording session into 30 min blocks and get 3rd block
%       [pos_block,spikes_block] = minions.sessionBlocks(pos,spikes,4,3)
%
%       % split 30 min recording session into 15 min blocks and get 1st block
%       [pos_block,spikes_block] = minions.sessionBlocks(pos,spikes,2,1)
%
% Written by BRK 2017

function [pos_block,spikes_block] = sessionBlocks(pos,spikes,numBlocks,block)

%% determine block length (# of samples)
blockLength = floor(size(pos,1)/numBlocks);

%% extract positions
if block == 1                   % first time block
    t = pos(1:blockLength,1); % position times
    x = pos(1:blockLength,2); % x-coordinate
    y = pos(1:blockLength,3); % y-coordinate
elseif block == numBlocks       % last time block
    t = pos((numBlocks-1)*blockLength:(numBlocks-1)*blockLength+(blockLength-1),1);
    x = pos((numBlocks-1)*blockLength:(numBlocks-1)*blockLength+(blockLength-1),2);
    y = pos((numBlocks-1)*blockLength:(numBlocks-1)*blockLength+(blockLength-1),3);
else                            % middle time blocks
    t = pos((block-1)*blockLength+1:block*blockLength,1);
    x = pos((block-1)*blockLength+1:block*blockLength,2);
    y = pos((block-1)*blockLength+1:block*blockLength,3);
end

%% extract 2nd x and y if array is N x 5
if size(pos,2) == 5
    if block == 1                
        x2 = pos(1:blockLength,4);                    
        y2 = pos(1:blockLength,5);              
    elseif block == numBlocks      
        x2 = pos((numBlocks-1)*blockLength:(numBlocks-1)*blockLength+(blockLength-1),4);
        y2 = pos((numBlocks-1)*blockLength:(numBlocks-1)*blockLength+(blockLength-1),5);
    else                          
        x2 = pos((block-1)*blockLength+1:block*blockLength,4);
        y2 = pos((block-1)*blockLength+1:block*blockLength,5);
    end
    pos_block = [t x y x2 y2];
else
    pos_block = [t x y];
end

%% extract spikes
if ~isempty(spikes)
    times = pos(:,1);
    if block == 1                  % first time block
        s = spikes(spikes <= times(blockLength)); 
    elseif block == numBlocks      % last time block
        s = spikes(times((numBlocks-1)*blockLength) < spikes);
    else                           % middle time blocks
        s = spikes(spikes <= times(block*blockLength));
        s = spikes(s > times((block-1)*blockLength));
    end
else
    s = [];
end
spikes_block = s;