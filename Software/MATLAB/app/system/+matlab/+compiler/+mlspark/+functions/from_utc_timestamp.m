function col = from_utc_timestamp(inCol, timeZone)
    % FROM_UTC_TIMESTAMP Create a column from UTC columnn
    %
    % Example:
    %
    %     mc = from_utc_timestamp(col, timeZone)
    %  or
    %     mc = from_utc_timestamp(col, timeZoneCol)
    
    % Copyright 2020 MathWorks, Inc.
    
    if isa(timeZone, 'string') || isa(timeZone, 'char')
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.from_utc_timestamp(inCol.column, timeZone) ...
            );
    else
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.from_utc_timestamp(inCol.column, timeZone.column) ...
            );
    end
    
end %function
