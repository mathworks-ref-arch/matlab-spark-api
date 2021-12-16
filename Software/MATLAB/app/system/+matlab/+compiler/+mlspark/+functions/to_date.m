function col = to_date(dateCol, fmt)
    % TO_DATE Create a date column from a text column
    %
    % This function will return a new dataset, with the additional column
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column (which is still a string)
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     dt = to_date(dtc)
    %
    % A second argument can be used to specify the input format, e.g.
    %     dt = to_date(dtc, "yyyy-MM-dd HH:mm")
    
    %                 Copyright 2020 MathWorks, Inc.
    
    if nargin < 2
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.to_date(dateCol.column) ...
            );
    else
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.to_date(dateCol.column, fmt) ...
            );
    end
end %function
