function ds = table(obj, tableName)
    % TABLE Use DataFrameReader to get a table from Spark
    %
    % TABLE(obj, "my_table") will return a new dataset from the
    % corresponding Spark table.
    %
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/DataFrameReader.html#table-java.lang.String-

    % Copyright 2023 MathWorks, Inc.

    try
        jDataset = obj.dataFrameReader.table(tableName);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
end %function
