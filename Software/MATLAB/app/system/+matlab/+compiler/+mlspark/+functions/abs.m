function col = abs(inCol)
    % ABS Create an abs column from a column
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     dtc = DS.col("x_loc")
    %     % Convert this to a column with absolute values
    %     mc = abs(dtc)
    
    % Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.abs(inCol.column) ...
        );
end
