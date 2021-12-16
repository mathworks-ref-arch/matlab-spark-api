function ds = alias(obj, aliasName)
    % ALIAS Return a new Dataset with an alias set
    % (same as the AS method)
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
    %     % Returns a new Dataset with an alias set.
    %     newDataSet = myDataSet.alias("new name");
    %
    % Reference: 
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#alias-java.lang.String-

    % Copyright 2021 MathWorks, Inc.

    if isa(aliasName, 'char') || isa(aliasName, 'string')
        try
            newDataset = obj.dataset.alias(aliasName);
            ds = matlab.compiler.mlspark.Dataset(newDataset);
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
    else
        error('SPARK:ERROR', 'Wrong datatype for aliasName: must be a char array or string');
    end

end %function
