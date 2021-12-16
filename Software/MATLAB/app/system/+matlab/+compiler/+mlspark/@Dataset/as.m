function ds = as(obj, aliasName)
    % AS Return a new Dataset with an alias set
    % (same as the ALIAS method)
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
    %     % Returns a new Dataset with an alias set.
    %     newDataSet = myDataSet.as("new name");
    %
    % Reference: 
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#as-java.lang.String-

    % Copyright 2021 MathWorks, Inc.

    ds = alias(obj, aliasName);

end %function
