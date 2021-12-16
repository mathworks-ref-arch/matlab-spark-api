function col = lit(theObject)
    % LIT Creates a column containing a constant value
    %
    % This function will return a new column
    % Example:
    %
    %     mc = column("ColName")
    
    %                 Copyright 2021 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.lit(theObject) ...
        );
end %function
