function col = to_timestamp(dateCol, fmt)
    % TO_TIMESTAMP Create a timestamp column from a text column
    %
    % This function will return a new dataset, with the additional column
    % Example:
    %
    %     % DS is a dataset
    %     % Get datetime column (which is still a string)
    %     dtc = DS.col("date")
    %     % Convert this to a timestamp on the dataset
    %     ts = to_timestamp(dtc)
    %
    % A second argument can be used to specify the input format, e.g.
    %     ts = to_timestamp(dtc, "yyyy-MM-dd HH:mm")
        
    %                 Copyright 2020 MathWorks, Inc.
    
    if nargin < 2
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.to_timestamp(dateCol.column) ...
            );
    else
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.to_timestamp(dateCol.column, fmt) ...
            );
    end
end %function
