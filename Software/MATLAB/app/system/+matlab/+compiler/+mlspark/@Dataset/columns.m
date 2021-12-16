function cols = columns(obj, varargin)
    % COLUMNS Method to return column names from a dataset.
    %
    %  This will return a string array of the column names.
    %
    % Example:
    %
    %     % Create a dataset
    %     myLocation = '/test/*.parquet');
    %     myDataSet = spark...
    %         .read.format('parquet')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load(myLocation);
    %
    %     % Return column names
    %     cols = myDataSet.columns();

    % Copyright 2020-2021 MathWorks, Inc.

    try
        cols = string(obj.dataset.columns());
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end %function
