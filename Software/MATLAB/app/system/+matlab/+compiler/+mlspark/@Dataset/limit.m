function ds = limit(obj, numRows, varargin)
    % LIMIT Limit the number of rows in the dataset
    % Returns a new Dataset by taking the first n rows.
    
    % Copyright 2020-2021 MathWorks, Inc.

    try
        ds = matlab.compiler.mlspark.Dataset(obj.dataset.limit(numRows));
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
end %function
