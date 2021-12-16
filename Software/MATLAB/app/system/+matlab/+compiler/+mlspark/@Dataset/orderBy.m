function ds = orderBy(obj, varargin)
    % ORDERBY Method to select rows by name
    % (same as the SORT method)
    %
    % This method will return a new dataset, sorted by the column names provided
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
    %     % Sort the dataset using the specified columns
    %     sortedDataSet = myDataSet.orderBy("UniqueCarrier", "Day", "Month");    
    %
    % Reference: 
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#orderBy-java.lang.String-java.lang.String...-

    % Copyright 2021 MathWorks, Inc.
    
    ds = sort(obj, varargin{:});
    
end %function
