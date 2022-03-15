function createWheel(obj)
    % createWheel Create a wheel for the Python package
    %

    % Copyright 2022 The MathWorks, Inc.

    old = cd(obj.OutputDir);
    goBack = onCleanup(@() cd(old));

    [r,s] = system("python3 setup.py bdist_wheel");
    if r ~= 0
        disp(s);
        error('SPARK_API:wheel_creation_error', ...
            'Problems building wheel\n');
    else
        wheel = obj.getWheelFile();
        fprintf("Created %s\n", wheel);
    end

end
