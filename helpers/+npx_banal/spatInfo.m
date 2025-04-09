function si = spatInfo(maps_struct)

si = nan(length(maps_struct), 1);
for i = 1:length(maps_struct)
    if ~isempty(maps_struct{i}.x)
        tmp = analyses.mapStatsPDF(maps_struct{i});
        si(i) = tmp.content;
    end
end