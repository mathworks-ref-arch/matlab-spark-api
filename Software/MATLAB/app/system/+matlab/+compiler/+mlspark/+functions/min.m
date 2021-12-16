function col = min(inCol)
    % MIN Create a min column from a column
    %
    % Example:
    %
    %     % DS is a datasetf
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     mc = min(dtc)
    
    % Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.min(inCol.column) ...
        );
end
