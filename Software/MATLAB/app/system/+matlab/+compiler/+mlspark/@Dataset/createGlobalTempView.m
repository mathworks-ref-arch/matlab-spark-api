function createGlobalTempView(obj, name)
    % CREATEGLOBALTEMPVIEW Create temporary global database view of dataset
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
    %     myDataSet.createGlobalTempView('my_table_name');

    % Copyright 2020-2021 MathWorks, Inc.

    try
        obj.dataset.createGlobalTempView(name);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end %function
