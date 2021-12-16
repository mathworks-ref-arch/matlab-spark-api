function col = date_sub(dateCol, numDays)
    % DATE_SUB Subtract days from a date column
    %
    % This function will return a new column, with a certain number of days
    % subtracted.
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column (which is still a string)
    %     dtc = DS.col("date")
    %     % Move the dates 10 days back
    %     dt = date_add(dtc, 10)
    
    %                 Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.date_sub(dateCol.column, numDays) ...
        );

end %function
