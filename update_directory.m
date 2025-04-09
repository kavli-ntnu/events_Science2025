
% Define the base directory for code
baseDir = 'N:\benjamka\events_Science2025\';

% Find and replace directories as needed
oldPath = 'C:\Users\benjamka\OneDrive - NTNU\LEC\paper';
newPath = 'N:\benjamka\events_Science2025\';

for iReplace = 1:2

    % Perform a second pass for double slash notation
    if iReplace == 2
        oldPath = strrep(oldPath, '\', '\\');
        newPath = strrep(newPath, '\', '\\');
    end

    % Get list of all .m files recursively
    fileList = dir(fullfile(baseDir, '**', '*.m'));
    % Loop through each file and perform replacement
    for i = 1:length(fileList)
        filePath = fullfile(fileList(i).folder, fileList(i).name);
        % Read file content
        fid = fopen(filePath, 'r');
        if fid == -1
            warning('Could not open file: %s', filePath);
            continue;
        end
        fileContent = fread(fid, '*char')';
        fclose(fid);
        % Replace occurrences of oldPath with newPath
        newContent = strrep(fileContent, oldPath, newPath);
        % Only overwrite if changes were made
        if ~strcmp(fileContent, newContent)
            fid = fopen(filePath, 'w');
            fwrite(fid, newContent);
            fclose(fid);
            fprintf('Updated: %s\n', filePath);
        end
    end

end