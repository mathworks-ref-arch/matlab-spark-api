function column = apply(obj, colName)
    % APPLY method returns the selected Dataset column name as a Column object.
    % 
    % Note: The column name can also reference a nested column such as a.b.
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
    %     % Retrieve a named column
    %     column = myDataSet.apply("Day");
    %
    % Reference: 
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#apply-java.lang.String-

    % Copyright 2021 MathWorks, Inc.

    if isa(colName, 'char') || isa(colName, 'string')
        try
            jCol = obj.dataset.apply(colName);
            column = matlab.compiler.mlspark.Column(jCol);
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
    else
        error('SPARK:ERROR', 'Wrong datatype for colName: must be a char array or string');
    end

end %function
