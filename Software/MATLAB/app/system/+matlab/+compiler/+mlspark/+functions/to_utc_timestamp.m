function col = to_utc_timestamp(inCol, timeZone)
    % TO_UTC_TIMESTAMP Create a UTC column from TZ columnn
    %
    % Example:
    %
    %     mc = to_utc_timestamp(col, timeZone)
    %  or
    %     mc = to_utc_timestamp(col, timeZoneCol)
    
    % Copyright 2020 MathWorks, Inc.
    
    if isa(timeZone, 'string') || isa(timeZone, 'char')
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.to_utc_timestamp(inCol.column, timeZone) ...
            );
    else
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.to_utc_timestamp(inCol.column, timeZone.column) ...
            );
    end
    
end %function
