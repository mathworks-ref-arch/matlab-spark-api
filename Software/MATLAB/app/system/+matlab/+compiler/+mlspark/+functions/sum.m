function col = sum(inCol)
    % SUM Create a sum column from a column
    %
    % Example:
    %
    %     % DS is a datasetf
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     mc = sum(dtc)
    
    % Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.sum(inCol.column) ...
        );
end %function
