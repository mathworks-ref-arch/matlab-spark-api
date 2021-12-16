function col = date_add(dateCol, numDays)
    % DATE_ADD Add days to a date column
    %
    % This function will return a new column, with a certain number of days
    % added.
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column (which is still a string)
    %     dtc = DS.col("date")
    %     % Move the dates one week ahead
    %     dt = date_add(dtc, 7)
    
    %                 Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.date_add(dateCol.column, numDays) ...
        );

end %function
