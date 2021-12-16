function ds = where(obj, varargin)
    % WHERE Method to filter rows using the given SQL expression
    % (same as the FILTER method)
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
    %     filterDataSet = myDataSet.where("UniqueCarrier LIKE 'AA'");
    %
    % Reference
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#where-org.apache.spark.sql.Column-

    % Copyright 2021 MathWorks, Inc.

    ds = filter(obj, varargin{:});

end %function
