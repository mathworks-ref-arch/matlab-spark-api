function result = isStreaming(obj)
    % ISSTREAMING Method that returns true if Dataset source streams continuous data.
    % 
    % ISSTREAMING returns a logical (true/false) value that indicates whether
    % this Dataset contains one or more sources that continuously streams data
    % as it arrives. A Dataset that reads data from a streaming source must be
    % executed as a StreamingQuery using the start() method in DataStreamWriter.
    % Methods that return a single answer, e.g. count() or collect(), will throw
    % an AnalysisException when there is a streaming source present.
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
    %     % Is the Dataset streaming continuous data?
    %     result = myDataSet.isStreaming();  %or: isStreaming(myDataSet)
    %
    % Reference: 
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#isStreaming--

    % Copyright 2021 MathWorks, Inc.

    try
        result = obj.dataset.isStreaming();
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
end %function
