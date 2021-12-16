function col = date_format(dateCol, fmt)
    % DATE_FORMAT Create a text column from a date column in spec. format
    %
    %     % DS is a dataset
    %     % Get datetime column
    %     dtc = DS.col("date")
    %     % Convert this to a date on the dataset
    %     fmt = "yyyy-mm-dd";
    %     dt = date_format(dtc, fmt)
    
    % Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.date_format(dateCol.column, fmt) ...
        );
end %function
