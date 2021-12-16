function col = month(dateCol)
    % MONTH Create a month column from a datetime column
    %
    % This function will return a new dataset, with the additional column
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     mc = month(dtc)
    
    %                 Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.month(dateCol.column) ...
    );
    
end %function
