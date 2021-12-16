function createOrReplaceGlobalTempView(obj, name)
    % CREATEORREPLACEGLOBALTEMPVIEW Create global temporary database view of dataset
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
    %     myDataSet.createOrReplaceGlobalTempView('my_table_name');

    % Copyright 2020-2021 MathWorks, Inc.

    try
        obj.dataset.createOrReplaceGlobalTempView(name);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end %function
