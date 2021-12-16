function ds = withColumnRenamed(obj, existingName, newName)
    % WITHCOLUMNRENAMED Method to return a new Dataset with one renamed column.
    %
    % Returns a new Dataset with the specified column existingName renamed as
    % newName.
    %
    % If the existingName column doesn't exist, this is a no-op.
    %
    %    % Example:
    %
    %     % Create a dataset
    %     myLocation = '/test/*.parquet');
    %     myDataSet = spark...
    %         .read.format('parquet')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load(myLocation);
    %
    %     % Create a new dataset without the specified columns
    %     newDataSet = myDataSet.withColumnRenamed("UniqueCarrier", "Company");
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#withColumnRenamed-java.lang.String-java.lang.String-

    % Copyright 2021 MathWorks, Inc.

    % Get the requested column names (existing and new)
    % Note: either of the columns may be a char array or a string
    existingName = string(existingName);
    newName      = string(newName);

    % Process the Spark API action and return a new MATLAB Dataset object
    try
        jDataset = obj.dataset.withColumnRenamed(existingName, newName);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
end %function
