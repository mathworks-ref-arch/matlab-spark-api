function col = round(inCol, scale)
    % ROUND Create a rounded column from a column
    %
    % 
    % Example:
    %
    %     % DS is a datasetf
    %     % Get datetime column
    %     dtc = DS.col("Temperatur")
    %     mc = round(dtc)
    %     % or
    %     mc = round(dtc,2)
    
    %                 Copyright 2020 MathWorks, Inc.
    
    if nargin < 2
        scale = 0;
    end
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.round(inCol.column, scale) ...
        );

end %function
