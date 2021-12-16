function newDS = withColumn(obj, name, newCol)
    % WITHCOLUMN Create a new column in the dataset
    %
    % This function will return a new dataset, with the additional column
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
    %     % Filter the dataset given conditions
    %     DS.withColumn('DistanceInKm', DS.col('Distance').multiply(.001));
    
    % Copyright 2020-2021 MathWorks, Inc.
    
    try
        if isa(newCol, 'org.apache.spark.sql.Column')
            results = obj.dataset.withColumn(name, newCol);
        else
            results = obj.dataset.withColumn(name, newCol.column);
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

    newDS = matlab.compiler.mlspark.Dataset(results);

end %function
