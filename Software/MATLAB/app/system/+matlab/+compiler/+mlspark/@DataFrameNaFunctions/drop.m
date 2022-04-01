function DS = drop(obj, varargin)
    % drop Drop rows in Dataset

    % Copyright 2022 MathWorks, Inc.

    DS = matlab.compiler.mlspark.Dataset(...
        obj.na.drop(varargin{:}) ...
        );

end