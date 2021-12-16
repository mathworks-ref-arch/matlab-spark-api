function col = column(name)
    % COLUMN Create a copy of an existing dataset column with the 
    % specified name. 
    %
    % 
    % Example:
    %
    %     myDataSet.withColumn("colCopyName", ...
    %              functions.column("originalColumnName"));
    
    %                 Copyright 2021 MathWorks, Inc.
    
    if isstring(name)
        col = matlab.compiler.mlspark.Column(...
            org.apache.spark.sql.functions.column(name) ...
            );
    else
        error('SPARK:ERROR', ...
            'The new column name must be specified with a String');
    end
end %function
