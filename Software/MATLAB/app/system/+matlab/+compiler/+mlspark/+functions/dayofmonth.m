function col = dayofmonth(dateCol)
    % DAYOFMONTH Create a day-of-month column from a datetime column
    %
    % This function will return a new dataset, with the additional column
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     mc = dayofmonth(dtc)
    
    %                 Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.dayofmonth(dateCol.column) ...
        );

end %function
