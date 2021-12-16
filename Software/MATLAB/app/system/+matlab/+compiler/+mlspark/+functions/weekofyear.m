function col = weekofyear(inCol)
    % WEEKOFYEAR Create a week-of-year column from a datetime column
    %
    % This function will return a new colum
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     mc = weekofyear(dtc)
    
    %                 Copyright 2020 MathWorks, Inc.    
    
    col = matlab.compiler.mlspark.Column( ...
        org.apache.spark.sql.functions.weekofyear(inCol.column) ...
        );
end
