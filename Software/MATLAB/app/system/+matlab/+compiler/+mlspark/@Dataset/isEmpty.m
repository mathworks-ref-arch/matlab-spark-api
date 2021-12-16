function result = isEmpty(obj)
    % ISEMPTY Method that returns true if the Dataset is empty.
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
    %     % Is the Dataset empty?
    %     result = myDataSet.isEmpty();  %or: isEmpty(myDataSet)
    %
    % Reference: 
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#isEmpty--

    % Copyright 2021 MathWorks, Inc.

    try
        result = obj.dataset.isEmpty();
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
end %function
