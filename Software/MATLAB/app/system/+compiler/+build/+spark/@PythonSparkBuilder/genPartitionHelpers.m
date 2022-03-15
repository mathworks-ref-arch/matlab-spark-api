function genPartitionHelpers(obj)
    % genPartitionHelpers 

    % Copyright 2022 The MathWorks, Inc.

    if ~isfolder(obj.OutputDir)
        mkdir(obj.OutputDir);
        % Make OutputDir an absolute path
        back = cd(obj.OutputDir);
        obj.OutputDir = pwd;
        cd(back);
    end

    obj.GenMatlabDir = fullfile(obj.OutputDir, 'matlab_helpers');
    if ~exist(obj.GenMatlabDir, 'dir')
        mkdir(obj.GenMatlabDir);
    end

    obj.HelperFiles = string.empty;

    for k=1:length(obj.Files)
        genPartitionHelperFiles(obj, obj.Files(k));
    end
end
