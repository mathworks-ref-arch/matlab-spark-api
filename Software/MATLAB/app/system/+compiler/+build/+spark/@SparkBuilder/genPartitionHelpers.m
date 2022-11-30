function genPartitionHelpers(obj)
    % genPartitionHelpers Create helper MATLAB functions
    %

    % Copyright 2022 The MathWorks, Inc.

    obj.GenMatlabDir = fullfile(obj.outputFolder, 'matlab_helpers');
    if ~exist(obj.GenMatlabDir, 'dir')
        mkdir(obj.GenMatlabDir);
    end

    for k=1:length(obj.javaClasses)
        JC = obj.javaClasses(k);
        genPartitionHelpers(JC);
    end
end

