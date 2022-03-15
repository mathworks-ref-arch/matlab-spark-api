function PSB = pythonPackage(varargin)
    % compiler.build.spark.pythonPackage Spark builder for Python
    %
    %  Please refer to the documentation delivered in this package for
    %  PythonSparkBuilder for usage examples.

    % Copyright 2022 MathWorks, Inc.

    % TODO: These may not be the only two cases
    if nargin == 1 && isa(varargin{1}, "compiler.build.PythonPackageOptions")
        buildOpts = varargin{1};
    else
        buildOpts = compiler.build.PythonPackageOptions(varargin{:});
    end

    PSB = compiler.build.spark.PythonSparkBuilder(buildOpts);

    PSB.build()

end
