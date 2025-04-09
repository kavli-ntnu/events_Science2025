
% x = times
% y = values
% thresh = threshold
% dur = minimum duration of state
% gap = minimum time between states

function [start,stop] = threshold(x,y,thresh,dur,gap)

start = [];
stop = [];
above_times = x(y > thresh);

% only keep times when there is another event within duration
d = diff(above_times);
count = 1;
times = [];
for i = 2:length(above_times)-1
   if d(i-1) <= dur
      times(count:count+1) = above_times(i-1:i);
      count = count+2;
   end
end
if ~isempty(times)
    above_times = unique(times);
    
    % separate into intervals
    d = diff(above_times) >= gap;
    d2 = find(d == 0);
    toRemove = find(diff(d2) == 1)+1;
    startInds = find(d == 0);
    startInds(toRemove) = [];
    row = 1;
    above_ints = nan(length(startInds),2);
    for i = startInds
        above_ints(row,1) = above_times(i);
        intLength = find(d(i:end) == 1,1) - 1;
        if isempty(intLength)
            continue
        end
        above_ints(row,2) = above_times(i+intLength);
        row = row + 1;
    end
    
    % remove intervals shorter than duration
    tooShort = (above_ints(:,2)-above_ints(:,1)) < dur;
    above_ints = above_ints(~tooShort,:);
    if ~isempty(above_ints)
        above_ints = above_ints(~any(isnan(above_ints),2),:);
        start = above_ints(:,1);
        stop = above_ints(:,2);
    end
end