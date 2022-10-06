function opts = PythonPackageOptions(varargin)
    % PythonPackageOptions Helper method for release compatibility
    %
    % This function will simply return an entry of
    % compiler.build.PythonPackageOptions, provided this is shippng with
    % this release. If used in an earlier release, it will try to
    % instantiate a similar class, to provide some compatibility.
    %
    % In the case of the compatibility class, no guarantees are made of
    % full compatibility.
    
    % Copyright 2022 MathWorks, Inc.
    
    
    if compiler.build.spark.internal.hasShippingPythonPackage()
        % Use the shipping functionality.
        opts = compiler.build.PythonPackageOptions(varargin{:});
    else
        % compiler.build.PythonPackageOptions was introduced in R2021a
        % If this is run with an earlier version, we provide a simple
        % wrapper, trying to encompass the general functionality of the
        % other object.
        opts = compiler.build.spark.internal.PythonPackageOptions(varargin{:});
    end
    
end
