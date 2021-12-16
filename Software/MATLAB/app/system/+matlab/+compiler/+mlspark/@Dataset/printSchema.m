function printSchema(obj, varargin)
    % printSchema Display the Dataset's underlying schema in the console
    %
    % Example:
    %
    %     DS.printSchema()
    
    % Copyright 2020-2021 The MathWorks, Inc.

    try
        obj.dataset.printSchema();
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
end
