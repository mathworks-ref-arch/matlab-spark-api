function clean(obj)
    % clean Clean the builld

    % Copyright 2022 The MathWorks, Inc.

    if isfolder(obj.OutputDir)
        fprintf("Removing %s to ensure clean build ...\n", obj.OutputDir);
        rmdir(obj.OutputDir, 's');
    end

end
