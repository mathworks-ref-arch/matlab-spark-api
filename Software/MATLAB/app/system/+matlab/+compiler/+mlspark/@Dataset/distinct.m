function ds = distinct(obj)
    % DISTINCT Return distinct rows from the input Dataset.
    %
    % Returns a new Dataset with unique rows
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
    %      % Show the unique set of machines from this Dataset
    %      myDataSet.select("MachineType").distinct().show();

    % Copyright 2021 MathWorks, Inc.

    try
        ds = matlab.compiler.mlspark.Dataset(obj.dataset.distinct());
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end
