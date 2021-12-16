function col = dayofyear(inCol)
    % DAYOFYEAR Create a day-of-year column from a datetime column
    %
    % This function will return a new dataset, with the additional column
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     mc = dayofyear(dtc)
    
    %                 Copyright 2020 MathWorks, Inc.    
    
    col = matlab.compiler.mlspark.Column( ...
        org.apache.spark.sql.functions.dayofyear(inCol.column) ...
        );
end
