
function probeNum = getProbeID(d, folder, probeName)

% match probe name to serial number
splits = regexp(folder,'\','split');
files = dir([strjoin(splits(1:end-1),'\'),'\*.sn']);
if numel(files)
    flag = true;
    i = 1;
    while flag
        if i > numel(files)
            error(sprintf('Failed to find .sn file for probe ''%s'' in the animal''s parent folder.',probeName))
        end
        if strfind(files(i).name,probeName)
            splits2 = strsplit(files(i).name,'_');
            if strcmpi(splits2{2},probeName)
                probeSN = splits2{end}(1:end-3);
                flag = false;
            else
                i = i + 1;
            end
        else
            i = i + 1;
        end
    end
end

% match serial number to probe number/index
flag = true;
probeNum = 1;
while flag
    if probeNum > numel(d.probes)
        error(sprintf('Hmmm...I didn''t find your probe ''%s'' :/',probeName))
    end
    if strcmp(num2str(d.probes(probeNum).metadata.ap.imDatPrb_sn),probeSN)
        flag = false;
    else
        probeNum = probeNum + 1;
    end
end