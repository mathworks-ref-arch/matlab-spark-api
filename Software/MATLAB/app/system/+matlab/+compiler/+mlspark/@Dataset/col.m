function colObj = col(obj, colName)
    % COL Retrieve a column object from the dataset
    %
    % Selects column based on the column name and returns it as a Column.
    % 
    % Example:
    %
    %     % Create a dataset
    %     myLocation = '/test/*.parquet');
    %     DS = spark...
    %         .read.format('parquet')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load(myLocation);
    %
    %     % Return a Column object that represents the 'Distance' column
    %     myCol = DS.col('Distance');
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#col-java.lang.String-
    
    % Copyright 2020-2021 MathWorks, Inc.
    
    try
        colObj = matlab.compiler.mlspark.Column(obj.dataset.col(colName));
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
end %function
