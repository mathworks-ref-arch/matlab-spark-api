function col = max(inCol)
    % MAX Create a max column from a column
    %
    % Example:
    %
    %     % DS is a datasetf
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     mc = max(dtc)
    
    % Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.max(inCol.column) ...
        );
end
