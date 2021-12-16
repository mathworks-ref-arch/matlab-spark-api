function changeLineInFile(fileName, rx, type, str)
    % changeLineInFile Changes a line in an existing file
    %
    % This is an internal function, and not part of the API.
    %
    % This function can be used to adapt a text file. It takes the following
    % arguments:
    %   fileName - The name of the file to change
    %   rx - a regular expression for finding the line to change
    %   type - the type of change to make. Can be prepend, swap or append
    %   str - the string to insert.
    %
    % The arguments rx, type and str can all be string arrays. If any of
    % them is, rx has to be too. This can be used to swap several lines in
    % a file.
    
    % Copyright 2021 MathWorks, Inc.
    
    narginchk(4, 4);
    
    srcText = fileread(fileName);
    
    % Convert to string, if these are chars.
    rx = string(rx);
    type = string(type);
    str = string(str);
    
    nRx = numel(rx);
    nType = numel(type);
    nStr = numel(str);
    
    for k=1:nRx
        tRx = rx(k);
        if nType > 1
            tType = type(k);
        else
            tType = type;
        end
        if nStr > 1
            tStr = str(k);
        else
            tStr = str;
        end
        
        src = i_changeLineInFile(srcText, tRx, tType, tStr);
        
    end
    
    fh = fopen(fileName, "w");
    if fh < 0
        error("SparkAPI:Error", "Couldn't open %s for writing.\n", fileName);
    end
    fprintf(fh, "%s", src);
    fclose(fh);
    
end

function src = i_changeLineInFile(src, rx, type, str)
    switch type
        case "prepend"
            src = regexprep(src, rx, str + "$1", "preservecase");
        case "append"
            src = regexprep(src, rx, "$1" + str, "preservecase");
        case "insert"
            src = regexprep(src, rx, str, "preservecase");
        otherwise
            error("SparkAPI:Error", "Wrong type provided");
    end
end


