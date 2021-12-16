function ds = unpersist(obj, blocking)
    % UNPERSIST Method to mark the Dataset as non-persistent.
    %
    % This method will mark the Dataset as non-persistent, and remove all blocks
    % for it from memory and disk. This will not un-persist any cached data that
    % is built upon this Dataset.
    %
    % Inputs:
    %     blocking - optional logical (true/false) flag indicating whether to
    %                block until all blocks are deleted.
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
    %     % Un-persist the dataset
    %     sortedDataSet = myDataSet.unpersist();  %or: myDataSet.unpersist(true)
    %
    % Reference: 
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#unpersist-boolean-

    % Copyright 2021 MathWorks, Inc.

    if nargin < 2
        try
            newDataset = obj.dataset.unpersist();
            ds = matlab.compiler.mlspark.Dataset(newDataset);
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
    elseif islogical(blocking)
        try
            newDataset = obj.dataset.unpersist(blocking);
            ds = matlab.compiler.mlspark.Dataset(newDataset);
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
    else
        error('SPARK:ERROR', 'Wrong datatype for blocking: must be a logical (true/false) value');
    end
    
end %function
