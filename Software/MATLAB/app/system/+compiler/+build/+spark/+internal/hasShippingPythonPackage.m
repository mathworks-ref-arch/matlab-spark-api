function res = hasShippingPythonPackage()
    % hasShippingPythonPackage Check if pythonPackage exists in release
    %
    %
    
    % Copyright 2022 MathWorks, Inc.
    
    res = ~verLessThan('matlab', '9.10');
    % compiler.build.PythonPackageOptions was introduced in R2021a
    % If this is run with an earlier version, we provide a simple
    % wrapper, trying to encompass the general functionality of the
    % other object.
    
    
end
