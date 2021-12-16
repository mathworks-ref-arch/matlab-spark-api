function result = isLocal(obj)
    % ISLOCAL Method that returns true if methods can run locally.
    % 
    % ISLOCAL returns a logical (true/false) value that indicates whether the
    % collect and take methods can be run locally (without any Spark executors).
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
    %     % Is the Dataset local?
    %     result = myDataSet.isLocal();  %or: isLocal(myDataSet)
    %
    % Reference: 
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#isLocal--

    % Copyright 2021 MathWorks, Inc.

    try
        result = obj.dataset.isLocal();
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
end %function
