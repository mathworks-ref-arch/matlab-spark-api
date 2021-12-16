function col = unix_timestamp(dateCol, fmt)
    % UNIX_TIMESTAMP Create a unix_timestamp column
    %
    %     % Get datetime column (which is still a string)
    %     dtc = DS.col("date")
    %     ts1 = unix_timestamp()
    %     ts2 = unix_timestamp(dtc)
    %     ts2 = unix_timestamp(dtc, "yyyy-MM-dd")
    
    %                 Copyright 2020 MathWorks, Inc.
    
    if nargin == 0
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.unix_timestamp() ...
            );
    elseif nargin == 1
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.unix_timestamp(dateCol.column) ...
            );
    elseif nargin == 2
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.unix_timestamp(dateCol.column, fmt) ...
            );
    end
end %function
