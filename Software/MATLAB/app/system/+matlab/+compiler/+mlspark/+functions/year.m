function col = year(dateCol)
    % YEAR Create a year column from a datetime column
    %
    % This function will return a new dataset, with the additional column
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     yc = year(dtc)
    
    %                 Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.year(dateCol.column) ...
        );
end %function
