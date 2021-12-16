function ds = filter(obj, filterExpr)
    % FILTER Filter rows using the given SQL expression
    %
    % Filters rows using the specified SQL expression or Column object.
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
    %     % Filter the dataset based on a specified SQL expression
    %     filterDataSet = myDataSet.filter("UniqueCarrier LIKE 'AA'");
    %
    % Reference
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#filter-org.apache.spark.sql.Column-

    % Copyright 2020-2021 MathWorks, Inc.

    if isa(filterExpr, 'matlab.compiler.mlspark.Column')
        % Convert MATLAB Column object into Java Column object
        filterExpr = filterExpr.column;
    elseif isa(filterExpr, 'char') || isa(filterExpr, 'string')
        % Process filterExpr as-is
    else
        error('SPARK:ERROR', 'Wrong datatype for filter expression: must be a char array or string or Column object');
    end

    % Process the Spark API action and return a new MATLAB Dataset object
    try
        jDataset = obj.dataset.filter(filterExpr);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);

end %function
