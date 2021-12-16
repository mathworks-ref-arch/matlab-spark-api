function col = add_months(dateCol, numMonths)
    % ADD_MONTHS Add months to a date column
    %
    % This function will return a new column, with a certain number of
    % months added. If the number is negative, months will be subtracted.
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column (which is still a string)
    %     dtc = DS.col("date")
    %     % Move the dates 10 days back
    %     dt = date_add(dtc, 10)
    
    %                 Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.add_months(dateCol.column, numMonths) ...
        );

end %function
