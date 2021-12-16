function col = from_unixtime(inCol, fmt)
    % FROM_UNIXTIME Create a column with unixtime
    %
    % Example:
    %
    %     mc = from_unixtime(col)
    %  or
    %     mc = from_unixtime(col, "yyyy-MM-dd HH:mm:ss")
    
    % Copyright 2020 MathWorks, Inc.
    
    if nargin == 1
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.from_unixtime(inCol.column) ...
            );
    else
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.from_unixtime(inCol.column, fmt) ...
            );
    end
    
end %function
