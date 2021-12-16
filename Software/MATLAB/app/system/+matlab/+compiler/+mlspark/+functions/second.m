function col = second(dateCol)
    % SECOND Create a second column from a datetime column
    %
    % This function will return a new dataset, with the additional column
    % Example:
    %
    %     % DS is a datasetf
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     mc = second(dtc)
    
    %                 Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.second(dateCol.column) ...
        );

end %function
