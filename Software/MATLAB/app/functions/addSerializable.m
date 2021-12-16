function addSerializable(filename, oldLine, newLine)
    % ADDSERIALIZABLE
    
    % Copyright 2020 MathWorks, Inc.
    
    % Some basic error checking
    if ~(ischar(filename) || isStringScalar(filename))
        error('Expected filename of type character vector or string scalar');
    end
    if ~(ischar(oldLine) || isStringScalar(oldLine))
        error('Expected oldLine of type character vector or string scalar');
    end
    if ~(ischar(newLine) || isStringScalar(newLine))
        error('Expected newLine of type character vector or string scalar');
    end
    if strlength(filename) == 0 || strlength(oldLine) == 0 || strlength(newLine) == 0
        error('Empty arguments are not permitted');
    end
    
    
    if exist(filename, 'file') ~= 2
        error(['File not found: ', char(filename)]);
    end
    
    srcText = fileread(filename);
    % [p, f, e] = fileparts(filename);
    % fUpdated =[f, 'Updated', e];
    % filenameUpdated = fullfile(p, fUpdated);
    fileID  = fopen(filename, 'w');
    if fileID < 3
        error(['Error opening file: ', char(filename)]);
    else
        % Add a header to show the file has been updated
        fprintf(fileID, "// File updated using: %s to add 'implements Serializable'\n\n", mfilename);
        % Replace all occurrences
        newSrcText = replace(srcText, oldLine, newLine);
        fprintf(fileID, "%s", newSrcText);
    end
    
    fclose(fileID);
    
end